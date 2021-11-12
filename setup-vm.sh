#!/bin/bash
DEBUG=""
if [[ $1 == "-v" ]];then
    DEBUG="-vvv"
elif [[ $1 == "-vv" ]];then
    DEBUG="-vvvv"
fi

private_key=/Users/lanthean/.ssh/id_rsa_vm

# ansible-playbook -i hosts vm-one-time-setup.yml --extra-vars='target=all' --private-key=$private_key $DEBUG
ansible-playbook -i config/hosts config/yaml/setup-vm.yml --extra-vars='target=all' --private-key=$private_key $DEBUG
ansible-playbook -i localhost, config/yaml/setup-local.yml --private-key=$private_key $DEBUG
