#!/bin/bash

# ros2 run clearpath_generator_common generate_bash -s $WORKSPACE_PATH
# Note: never split build into several calls!
cd ros2_ws

BUILD_TYPE=RelWithDebInfo

rosdep install --from-paths src --ignore-src -r -y
colcon build \
  --symlink-install \
  --cmake-args \
    "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" \
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=On" \
  -Wall \
  -Wextra \
  -Wpedantic 


echo "Build finished, Source the 'ros2_ws/setup.bash' now"

cd -
