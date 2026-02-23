#!/bin/bash

cd "$(dirname "$0")/ansible"

# Install required collections
ansible-galaxy collection install -r requirements.yml >/dev/null

# Run playbook with logging
export ANSIBLE_LOG_PATH=../logs/ansible-$(date +%Y%m%d-%H%M%S).log
ansible-playbook -i inventory.yml sap-hana.yml --ask-vault-pass
