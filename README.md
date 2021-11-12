# lab_vm_ansible
Set of ansible scripts to help setup NGP machine.  

## Setup-env
Script will run 2 ansible-playbooks. First will be only called on hosts that are in section ngp2_2 in ./hosts and install python-simplejson to run standard ansible.
Second ansible-playbook will prepare environment for all hosts in ./hosts.

## Prerequisites:
Local machine SSH key must be authorized on remote machine. (Note: ssh-copy-id)

## Usage:  
### Prepare VM first
- Create VM in cloud.intinfra.com
- use image id 170 - NGPE 7.2 MGT latest-beta, 8GB RAM, 1 NIC (Latest unstable release of vanilla NGPE management station, branch 7.x. Delivered by Platform team on 2021-04-14. Currently: 7.2-00.B31beta + 2021Q1.)
- RAM - 4G
- Storage - 100G

### Setup the Vm second
sh setup-vm-one-time.sh

You can run ansible playbooks alone:
```sh
ansible-playbook -i hosts setup-vm.yml --extra-vars='target=<remote-machine or group in ./hosts>'
ansible-playbook -i hosts setup-ngp2_2.yml

ansible-playbook -i ./config/hosts ./config/yaml/git.yaml --extra-vars='target=all' --private-key=/Users/lanthean/.ssh/id_rsa_vm  
ansible-playbook -i ./config/hosts ./config/yaml/tools.yaml --extra-vars='target=all' --private-key=/Users/lanthean/.ssh/id_rsa_vm  
ansible-playbook -i ./config/hosts ./config/yaml/services.yaml --extra-vars='target=all' --private-key=/Users/lanthean/.ssh/id_rsa_vm  
```

