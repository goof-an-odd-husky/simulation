FROM althack/ros2:jazzy-cuda-gazebo

ENV DEBIAN_FRONTEND=noninteractive

ENV WORKSPACE=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utils
    apt-utils build-essential cmake curl default-jre dialog gedit gnupg grep \
    less lsb-release nano wget git \
    # Build Packages
    chrony espeak-ng gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
    gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio \
    gstreamer1.0-qt5 gstreamer1.0-tools gstreamer1.0-x libavcodec-dev libavformat-dev \
    libavutil-dev libboost-all-dev libboost-date-time-dev libbullet-dev libeigen3-dev \
    libglew-dev libglfw3-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
    libgtk-3-dev libjsoncpp-dev libpcl-dev libswscale-dev libtclap-dev neofetch \
    openssh-client openssh-server sshpass libgz-math7 \
    python3-colcon-common-extensions python3-colcon-installed-package-information \
    python3-colcon-override-check python3-flake8 python3-pip python3-pytest-cov \
    python3-rosdep python3-setuptools python3-vcstool \
    can-utils joystick \
    # ROS Packages
    ros-${ROS_DISTRO}-ament-cmake ros-${ROS_DISTRO}-can-msgs ros-${ROS_DISTRO}-cartographer-ros \
    ros-${ROS_DISTRO}-gripper-controllers ros-${ROS_DISTRO}-image-pipeline ros-${ROS_DISTRO}-imu-tools \
    ros-${ROS_DISTRO}-laser-proc ros-${ROS_DISTRO}-urg-c ros-${ROS_DISTRO}-moveit-configs-utils \
    ros-${ROS_DISTRO}-moveit-kinematics ros-${ROS_DISTRO}-moveit-planners ros-${ROS_DISTRO}-moveit-planners-chomp \
    ros-${ROS_DISTRO}-moveit-ros-move-group ros-${ROS_DISTRO}-moveit-ros-warehouse ros-${ROS_DISTRO}-moveit-setup-srdf-plugins \
    ros-${ROS_DISTRO}-moveit-simple-controller-manager ros-${ROS_DISTRO}-nav2-bringup ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-position-controllers ros-${ROS_DISTRO}-realsense2-camera ros-${ROS_DISTRO}-librealsense2 \
    ros-${ROS_DISTRO}-robotiq-description ros-${ROS_DISTRO}-rosidl-typesupport-c ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-sdformat-urdf ros-${ROS_DISTRO}-twist-stamper \
    # ROS2 Core Packages
    ros-${ROS_DISTRO}-depthai-ros-driver ros-${ROS_DISTRO}-diagnostic-aggregator ros-${ROS_DISTRO}-ffmpeg-image-transport \
    ros-${ROS_DISTRO}-gazebo-* ros-${ROS_DISTRO}-geodesy ros-${ROS_DISTRO}-microstrain-inertial-driver \
    ros-${ROS_DISTRO}-moveit ros-${ROS_DISTRO}-moveit-servo ros-${ROS_DISTRO}-nav2-* ros-${ROS_DISTRO}-nmea-msgs \
    ros-${ROS_DISTRO}-nmea-navsat-driver ros-${ROS_DISTRO}-ouster-ros ros-${ROS_DISTRO}-pcl-ros ros-${ROS_DISTRO}-phidgets-* \
    ros-${ROS_DISTRO}-ptz-action-server-msgs ros-${ROS_DISTRO}-rmw-cyclonedds-cpp ros-${ROS_DISTRO}-rmw-zenoh-cpp \
    ros-${ROS_DISTRO}-robot-upstart ros-${ROS_DISTRO}-robotiq-controllers ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers ros-${ROS_DISTRO}-ros2-socketcan ros-${ROS_DISTRO}-rosidl-generator-dds-idl \
    ros-${ROS_DISTRO}-rqt-* ros-${ROS_DISTRO}-test-msgs ros-${ROS_DISTRO}-urg-node ros-${ROS_DISTRO}-wireless-msgs \
    ros-${ROS_DISTRO}-wireless-watcher ros-${ROS_DISTRO}-xacro

RUN wget \
    https://packages.clearpathrobotics.com/public.key -O - | apt-key add - \
    && echo "deb https://packages.clearpathrobotics.com/stable/ubuntu $(lsb_release -cs) main" > \
    /etc/apt/sources.list.d/clearpath-latest.list \
    && wget \
    https://raw.githubusercontent.com/clearpathrobotics/public-rosdistro/master/rosdep/50-clearpath.list \
    -O /etc/ros/rosdep/sources.list.d/50-clearpath.list \
    && apt-get update && rosdep update \
    && apt-get install -y --no-install-recommends \
    ros-jazzy-clearpath-desktop ros-jazzy-clearpath-simulator

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${WORKSPACE}/husky-sim/ros2_ws \
    && ln -s ${WORKSPACE}/husky-sim/src ${WORKSPACE}/husky-sim/ros2_ws/src

RUN echo "if [ -f ${WORKSPACE}/husky-sim/ros2_ws/install/setup.bash ]; then source ${WORKSPACE}/husky-sim/ros2_ws/install/setup.bash; fi" >> /home/ros/.bashrc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR ${WORKSPACE}/husky-sim

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["tail", "-f", "/dev/null"]
