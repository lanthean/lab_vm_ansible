#!/bin/bash
###
#
#               d88b          dP                                                      oo dP       dP          
#               8`'8          88                                                         88       88          
#   88d888b.    d8b     .d888b88    dP   .dP 88d8b.d8b.    .d8888b. 88d888b. .d8888b. dP 88d888b. 88 .d8888b. 
#   88'  `88  d8P`8b    88'  `88    88   d8' 88'`88'`88    88'  `88 88'  `88 Y8ooooo. 88 88'  `88 88 88ooood8 
#   88        d8' `8bP  88.  .88    88 .88'  88  88  88    88.  .88 88    88       88 88 88.  .88 88 88.  ... 
#   dP        `888P'`YP `88888P8    8888P'   dP  dP  dP    `88888P8 dP    dP `88888P' dP 88Y8888' dP `88888P'  
#
#
# @created: 27/08/2021
#
# @author: lanthean
###

# Create VM in cloud.intinfra.com
# use image id 170 - NGPE 7.2 MGT latest-beta, 8GB RAM, 1 NIC (Latest unstable release of vanilla NGPE management station, branch 7.x. Delivered by Platform team on 2021-04-14. Currently: 7.2-00.B31beta + 2021Q1.)
# RAM - 4G
# Storage - 100G

echo " --"
echo "| Create VM"
echo "| - use image ID:170 - NGPE 7.2 MGT latest-beta, 8GB RAM, 1 NIC"
echo "| (Latest unstable release of vanilla NGPE management station, branch 7.x. Delivered by Platform team on 2021-04-14. Currently: 7.2-00.B31beta + 2021Q1.)"
echo "|"
echo "| Update ./config/hosts with the newly created VM's IP (can be multiple IPs, in case of multi VM deployment)"
echo " --"

read -p "Are You ready to continue ? [Y/n]: " yn
if [[ $yn == n ]];then
    exit 1
fi

GIT_CLONE=0
PATH=/opt/homebrew/bin:$PATH
RPATH=$(pwd)
DEBUG=""
if [[ $1 == "-v" ]];then
    DEBUG="-vvv"
elif [[ $1 == "-vv" ]];then
    DEBUG="-vvvv"
fi

private_key=/Users/lanthean/.ssh/id_rsa_vm

# Make sure dotfiles repository is ready and correct branch is checked out
if [[ ! -d ~/dotfiles ]];then
    GIT_CLONE=1
    git clone mb:/git/dotfiles.git
fi
pushd ~/dotfiles
branch=$(git rev-parse --abbrev-ref HEAD)
git checkout ngp


# Do variable substitution in yaml
sed -i "" "s|%RPATH%|${RPATH}/..|g" ${RPATH}/config/yaml/vm-one-time-setup.yaml

# Play
read -p "Run vm-one-time-setup? !ATTENTION: Run this ONLY ONCE! [y/N]: " yn
if [[ $yn == "y" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/vm-one-time-setup.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn
read -p "Run fdisk? !ATTENTION: Run this ONLY ONCE! [y/N]: " yn
if [[ $yn == "y" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/fdisk.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn
read -p "Run git? [Y/n]: " yn
if [[ $yn != "n" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/git.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn
read -p "Run tools? [Y/n]: " yn
if [[ $yn != "n" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/tools.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn
read -p "Run mount? [Y/n]: " yn
if [[ $yn != "n" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/mount.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn
read -p "Run services? [Y/n]: " yn
if [[ $yn != "n" ]];then
    ansible-playbook -i ${RPATH}/config/hosts ${RPATH}/config/yaml/services.yaml --extra-vars='target=all' --private-key=$private_key $DEBUG
fi; unset yn

# Revert variable substitution in yaml
sed -i "" "s|${RPATH}/..|%RPATH%|g" ${RPATH}/config/yaml/vm-one-time-setup.yaml

# Revert dotfiles repo back to original state (branch/remove if did not exist)
if [[ ${branch} != "main" ]];then
    git checkout $branch
fi
popd
if [[ GIT_CLONE=1 ]];then
    rm -rf ~/dotfiles
fi

# EOF
#