#!/bin/bash
set -e

cd ${WORKSPACE_PATH}

rm -rf install/ \
       build \
       scripts \
       sensors \
       platform \
       manipulators \
       robot.srdf \
       robot.srdf.xacro \
       robot.urdf.xacro \
       setup.bash

cd -
       
