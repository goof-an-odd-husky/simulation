#!/bin/bash

# ros2 run clearpath_generator_common generate_bash -s $WORKSPACE_PATH
# Note: never split build into several calls!
cd $WORKSPACE_PATH

BUILD_TYPE=RelWithDebInfo

colcon build \
  --allow-overriding \
  --symlink-install \
  --cmake-args \
    "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" \
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=On" \
  -Wall \
  -Wextra \
  -Wpedantic 
  # --merge-install \ # Good to have, but ignoring for now, we indeed will have conflicting names


echo "Build finished, Source the 'ros2_ws/setup.bash' now"

cd -
