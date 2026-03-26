#!/bin/bash
echo "Setting up ROOT_DIR to [$(pwd)]"
export ROOT_DIR=$(pwd)

echo "Setting up WORKSPACE_PATH to [${ROOT_DIR}/ros2_ws]"
export WORKSPACE_PATH=${ROOT_DIR}/ros2_ws
mkdir $WORKSPACE_PATH

source ${ROOT_DIR}/utils/set_or_update_bashrc_var.sh

update_bashrc_entry export "ROOT_DIR" "${ROOT_DIR}"
update_bashrc_entry export "WORKSPACE_PATH" "${WORKSPACE_PATH}"

update_bashrc_entry export "ROS_SYSTEM_SETUP" "/opt/ros/${ROS_DISTRO}/setup.bash"
update_bashrc_entry source ROS_SYSTEM_SETUP

update_bashrc_entry export "ROS_WORKSPACE_SOURCE" "${WORKSPACE_PATH}/install/setup.bash"
update_bashrc_entry source ROS_WORKSPACE_SOURCE

source ~/.bashrc

mkdir -p src/third_party
vcs import src/third_party < third_party.repos
vcs pull src/third_party

ln -sT ${ROOT_DIR}/src ${WORKSPACE_PATH}/src

sudo apt update

if ! [ -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
    echo "Initializing rosdep..."
    sudo rosdep init
else
    echo "rosdep is already initialized. Skipping 'rosdep init'."
fi

echo "Updating rosdep..."
rosdep update --rosdistro=$ROS_DISTRO

rosdep install \
        --from-paths ${ROOT_DIR}/src \
        --ignore-src -y -r \
        --rosdistro $ROS_DISTRO

source ${ROOT_DIR}/utils/ros2_env_info.sh

alias ros2env='ros2_env_info'
