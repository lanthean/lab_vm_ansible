#!/bin/sh
ansible-playbook -i config/hosts config/yaml/setup-foam.yml --extra-vars='target=all'
