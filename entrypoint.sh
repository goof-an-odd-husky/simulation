#!/bin/bash
set -e

echo "Entrypoint running as root..."

chown -R ros:ros /workspace

source /opt/ros/jazzy/setup.bash

if [ -z "$(ls -A /workspace/husky-sim/src)" ]; then
    echo "Workspace 'src' is empty. Skipping build scripts."
    echo "Please populate '/workspace/husky-sim/src' with your ROS packages."
else
    echo "Running workspace initialization and build as user 'ros'..."
    sudo -u ros -E -H bash -c " \
        git config --global --add safe.directory ${WORKSPACE}/husky-sim && \
        cd ${WORKSPACE}/husky-sim && \
        ./clean.sh && \
        ./init.sh && \
        ./build.sh"
fi

echo "---"
echo "ROS 2 Docker environment is ready."
echo "Dropping privileges and executing command..."
echo "---"

# Execute the command passed into the container (e.g., CMD) as the 'ros' user
exec sudo -u ros -E -H "$@"
