#!/bin/bash 

# Function to pretty-print ROS 2 environment variables with splitting by ":"
function ros2_env_info() {

    # Define an associative array of ROS 2 environment variables and their descriptions
    declare -A ros2_vars=(
        ["ROS_DISTRO"]="ROS 2 Distribution"
        ["ROS_NAMESPACE"]="ROS Namespace"
        ["WORKSPACE_PATH"]="Workspace Path"
        ["LD_LIBRARY_PATH"]="Library Path"
        ["AMENT_PREFIX_PATH"]="Ament Prefix Path"
        ["COLCON_DEFAULTS_FILE"]="Colcon Defaults File"
        ["COLCON_PREFIX_PATH"]="Colcon Prefix Path"
        ["RMW_IMPLEMENTATION"]="RMW Implementation"
        # TODO: add GZ_SIM variables
    )

    # Iterate over the associative array and print variable names, descriptions, and values
    for var in "${!ros2_vars[@]}"; do
        echo -e "${var}: ${ros2_vars[$var]}"
        value="${!var}"
        if [ -z "$value" ]; then
            # Variable is not set
            echo -e "    \033[1;31mNot Set\033[0m"
        else
            # Check if the variable contains a colon
            if [[ "$value" == *":"* ]]; then
                # Split the value by colon and print each entry on a new line with indentation
                IFS=':' read -ra ADDR <<< "$value"
                for entry in "${ADDR[@]}"; do
                    echo -e "    \033[1;32m$entry\033[0m"
                done
            else
                # Single value, print normally
                echo -e "    \033[1;32m$value\033[0m"
            fi
        fi
        echo
    done

    echo -e "===== PATH Variable =====\n"
    echo -e "\033[1;34m"

    # Replace colons with line breaks for better readability
    echo "$PATH" | tr ':' '\n'

    echo -e "\033[0m\n"
}