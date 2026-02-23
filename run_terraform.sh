#!/bin/bash
cd "$(dirname "$0")/terraform"

if command -v tofu &> /dev/null; then
    TF_CMD="tofu"
elif command -v terraform &> /dev/null; then
    TF_CMD="terraform"
else
    echo "Error: Neither tofu nor terraform is installed"
    exit 1
fi

# Enable logging
export TF_LOG=INFO
export TF_LOG_PATH=../logs/terraform-$(date +%Y%m%d-%H%M%S).log

if [ ! -d ".terraform" ]; then
    echo "Initializing with $TF_CMD..."
    $TF_CMD init
fi

$TF_CMD apply
