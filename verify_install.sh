#!/bin/bash

cd "$(dirname "$0")/ansible"

# Run verification playbook
ansible-playbook -i inventory.yml verify-hana.yml --ask-vault-pass
