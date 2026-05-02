FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    ros-dev-tools \
    ros-humble-ros-base \
    ros-humble-gazebo-* \
    ros-humble-cartographer \
    ros-humble-cartographer-ros \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-image-transport \
    ros-humble-compressed-image-transport \
    ros-humble-cv-bridge \
    ros-humble-vision-opencv \
    ros-humble-image-pipeline \
    ros-humble-rqt \
    ros-humble-rqt-common-plugins \
    python3-opencv \
    libopencv-dev \
    python3-colcon-common-extensions \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Webots & ROS 2 Bridge
RUN apt-get update && apt-get install -y software-properties-common && \
    wget -qO- https://cyberbotics.com/Cyberbotics.asc | tee /etc/apt/trusted.gpg.d/cyberbotics.asc && \
    apt-add-repository 'deb https://cyberbotics.com/debian/ binary-amd64/' && \
    apt-get update && apt-get install -y \
    webots \
    ros-humble-webots-ros2 \
    && rm -rf /var/lib/apt/lists/*                 

# Source ROS environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc

# Set the default models for TurtleBot3 and the Manipulator
ENV TURTLEBOT3_MODEL=waffle_pi
ENV OPENMANIPULATOR_MODEL=open_manipulator_x

# Create workspace
WORKDIR /root/ros2_ws/src

# Clone repositories
RUN git clone -b humble https://github.com/ROBOTIS-GIT/open_manipulator.git && \
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git && \
    git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git && \
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git && \
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git && \
    git clone -b humble https://github.com/UniversalRobots/Universal_Robots_ROS2_Description.git && \
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_manipulation.git

# Build workspace
WORKDIR /root/ros2_ws
RUN apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y --skip-keys "webots"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"

# Source workspace
RUN echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc

# Source ROS environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc
RUN echo "export ROS_DOMAIN_ID=30" >> ~/.bashrc
RUN echo "export GAZEBO_PLUGIN_PATH=$HOME/ros2_ws/build/ros2_gazebo:$GAZEBO_PLUGIN_PATH" >> ~/.bashrc
RUN echo "export TURTLEBOT3_MODEL=burger_cam" >> ~/.bashrc

# Backup workspace so it can be copied when container starts
RUN cp -r /root/ros2_ws /root/ros2_ws_image

CMD ["bash"]
