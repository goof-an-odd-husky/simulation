#!/bin/bash
# Usage:
#   update_bashrc_entry <mode> <var_name> [var_value]
#
# For mode "export":
#   Ensures a line like:
#       export VAR_NAME=VAR_VALUE
#   exists in ~/.bashrc.
#
# For mode "source":
#   - If var_value is provided, the line will be:
#         source var_value
#   - If var_value is omitted or empty, it defaults to:
#         source ${VAR_NAME}
#
# This version escapes regex metacharacters in var_value to avoid sed errors
# and checks for an exact match to prevent duplicate lines.
update_bashrc_entry() {
    local mode="$1"
    local var_name="$2"
    local var_value="$3"
    local bashrc="$HOME/.bashrc"

    if [ "$mode" = "export" ]; then
        if grep -Eq "^[[:space:]]*export[[:space:]]+$var_name=" "$bashrc"; then
            # Update the export line: only replace the value.
            sed -i -E "s|^(export[[:space:]]+$var_name=).*|\1$var_value|" "$bashrc"
            echo "Updated export $var_name in $bashrc"
        else
            echo "export $var_name=$var_value" >> "$bashrc"
            echo "Appended export $var_name to $bashrc"
        fi

    elif [ "$mode" = "source" ]; then
        # Default to referencing the variable if var_value is not provided.
        if [ -z "$var_value" ]; then
            var_value="\${$var_name}"
        fi

        # Escape regex metacharacters in var_value so that sed sees a literal string.
        local escaped_value
        escaped_value=$(echo "$var_value" | sed -e 's/[]\/.^$*+?()[{}|]/\\&/g')

        # Build a pattern that matches a line like:
        #   source ${ROS_WORKSPACE_SOURCE}
        local source_pattern="^[[:space:]]*source[[:space:]]+$escaped_value[[:space:]]*$"

        if grep -E -q "$source_pattern" "$bashrc"; then
            echo "Source line 'source $var_value' already exists in $bashrc"
        else
            # Remove any existing duplicate lines matching the pattern.
            sed -i -E "/$source_pattern/d" "$bashrc"
            echo "source $var_value" >> "$bashrc"
            echo "Appended source line for $var_name to $bashrc"
        fi
    else
        echo "Unsupported mode: $mode"
        return 1
    fi
}

# Example usage:
# 1. Create or update an export line:
#      update_bashrc_entry export "ROS_WORKSPACE_SOURCE" "${WORKSPACE_PATH}/setup.bash"
#
# 2. Create or update the corresponding source line (using default var reference):
#      update_bashrc_entry source ROS_WORKSPACE_SOURCE
