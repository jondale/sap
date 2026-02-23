#!/bin/bash
# Create or update terraform.tfvars interactively
# Reads existing values from terraform.tfvars and defaults from terraform.tfvars.example

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS="$SCRIPT_DIR/terraform/terraform.tfvars"
EXAMPLE="$SCRIPT_DIR/terraform/terraform.tfvars.example"

if [[ ! -f "$EXAMPLE" ]]; then
    echo "Error: terraform.tfvars.example not found"
    exit 1
fi

declare -A current_values
declare -A example_values
declare -A comments

# Parse a tfvars file and extract variable=value pairs
parse_tfvars() {
    local file="$1"
    local -n values="$2"

    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Match variable = value patterns
        if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            var="${BASH_REMATCH[1]}"
            val="${BASH_REMATCH[2]}"
            # Remove surrounding quotes if present
            val="${val%\"}"
            val="${val#\"}"
            values["$var"]="$val"
        fi
    done < "$file"
}

# Extract comments (lines before each variable) from example file
parse_comments() {
    local file="$1"
    local current_comment=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*#(.*)$ ]]; then
            current_comment="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
            var="${BASH_REMATCH[1]}"
            comments["$var"]="$current_comment"
            current_comment=""
        fi
    done < "$file"
}

# Load existing values if terraform.tfvars exists
if [[ -f "$TFVARS" ]]; then
    parse_tfvars "$TFVARS" current_values
    echo "Found existing terraform.tfvars with ${#current_values[@]} variables"
fi

# Load example values and comments
parse_tfvars "$EXAMPLE" example_values
parse_comments "$EXAMPLE"

echo ""
echo "Configure Terraform variables for SAP HANA deployment"
echo "======================================================"
echo "Press Enter to accept the default value shown in brackets."
echo ""

# Track variables in order they appear in example file
ordered_vars=()
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
        ordered_vars+=("${BASH_REMATCH[1]}")
    fi
done < "$EXAMPLE"

declare -A final_values

for var in "${ordered_vars[@]}"; do
    # Use current value if exists, otherwise use example value
    if [[ -n "${current_values[$var]}" ]]; then
        default="${current_values[$var]}"
        has_current=true
    else
        default="${example_values[$var]}"
        has_current=false
    fi

    # Show comment as description if available
    if [[ -n "${comments[$var]}" ]]; then
        echo "${comments[$var]}"
    fi

    if $has_current; then
        # Variable already exists, skip prompting
        final_values["$var"]="$default"
        echo "$var = $default (existing)"
    else
        # Prompt for new value
        read -r -p "$var [$default]: " input
        if [[ -z "$input" ]]; then
            final_values["$var"]="$default"
        else
            final_values["$var"]="$input"
        fi
    fi
    echo ""
done

# Write terraform.tfvars preserving structure from example
echo "Writing terraform.tfvars..."

{
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*#.*$ ]] || [[ -z "$line" ]]; then
            # Preserve comments and empty lines
            echo "$line"
        elif [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
            var="${BASH_REMATCH[1]}"
            val="${final_values[$var]}"
            # Quote strings, don't quote numbers
            if [[ "$val" =~ ^[0-9]+$ ]]; then
                echo "$var = $val"
            else
                echo "$var = \"$val\""
            fi
        fi
    done < "$EXAMPLE"
} > "$TFVARS"

echo "Done! terraform.tfvars has been created/updated."
echo ""
echo "Review your settings:"
echo "---------------------"
grep -v '^#' "$TFVARS" | grep -v '^$'
