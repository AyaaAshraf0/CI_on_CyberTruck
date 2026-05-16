FROM osrf/ros:humble-desktop-full

WORKDIR /app

# The base image ships a ROS 2 apt source with the PGP key stored inline —
# it may be a .list file OR a deb822 .sources file depending on image version.
# Either way, any ros-related source entry with a conflicting Signed-By will
# cause "E: The list of sources could not be read". Wipe all of them.
RUN find /etc/apt/sources.list.d/ -name "*ros*" -delete

# Register the current ROS 2 GPG key as a proper keyring file.
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list

    RUN apt-get update \
    && apt-get install -y \
        python3-rosdep \
        python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Copy source into the cyber_truck workspace
COPY src/ cyber_truck/src/

# Update rosdep index
RUN rosdep update

# Install all declared ROS package dependencies
RUN apt-get update \
    && rosdep install --from-paths cyber_truck/src --ignore-src -r -y \
    && rm -rf /var/lib/apt/lists/*

# Persist resource/workspace paths for runtime
ENV IGN_GAZEBO_RESOURCE_PATH=/app/cyber_truck/src
ENV WORKSPACE=/app/cyber_truck

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]