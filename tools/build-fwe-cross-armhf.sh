#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -eo pipefail

WITH_IWAVE_GPS_SUPPORT="false"
WITH_ROS2_SUPPORT="false"

parse_args() {
    while [ "$#" -gt 0 ]; do
        case $1 in
        --with-iwave-gps-support)
            WITH_IWAVE_GPS_SUPPORT="true"
            ;;
        --with-ros2-support)
            WITH_ROS2_SUPPORT="true"
            ;;
        --help)
            echo "Usage: $0 [OPTION]"
            echo "  --with-ros2-support       Build with ROS2 support"
            echo "  --with-iwave-gps-support  Build with iWave GPS support"
            exit 0
            ;;
        esac
        shift
    done
}

parse_args "$@"

NATIVE_PREFIX="/usr/local/`gcc -dumpmachine`"
export PATH=${NATIVE_PREFIX}/bin:${PATH}

CMAKE_OPTIONS="
    -DFWE_STATIC_LINK=On
    -DFWE_STRIP_SYMBOLS=On
    -DFWE_SECURITY_COMPILE_FLAGS=On
    -DCMAKE_TOOLCHAIN_FILE=/usr/local/arm-linux-gnueabihf/lib/cmake/armhf-toolchain.cmake \
    -DBUILD_TESTING=Off"
if ${WITH_IWAVE_GPS_SUPPORT}; then
    CMAKE_OPTIONS="${CMAKE_OPTIONS} -DFWE_FEATURE_IWAVE_GPS=On"
fi
if ${WITH_ROS2_SUPPORT}; then
    CMAKE_OPTIONS="${CMAKE_OPTIONS} -DFWE_FEATURE_ROS2=On"
fi

if ${WITH_ROS2_SUPPORT}; then
    source /opt/ros/galactic/setup.bash
    colcon build --cmake-args ${CMAKE_OPTIONS}
else
    mkdir -p build && cd build
    cmake ${CMAKE_OPTIONS} ..
    make -j`nproc`
fi
