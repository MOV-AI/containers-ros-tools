# This Dockerfile is used to build an headless vnc image based on Ubuntu
ARG DOCKER_REGISTRY="pubregistry.aws.cloud.mov.ai"
FROM ${DOCKER_REGISTRY}/ce/movai-base-focal:v2.4.5

LABEL description="MOV.AI Graphical Tools"
LABEL maintainer="devops@mov.ai"
LABEL movai="ros-tools"
LABEL environment="develop"

ARG USER_ID=1000
ARG USER_NAME=movai
ARG USER_HOME=/headless
ARG ROS_VERSION="noetic"
ARG ROS_GPG_KEY=C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

ARG VNC_PASSWORD="movai"
ARG ROS_MASTER="ros-master"
ARG ROS_MASTER_PORT="11311"

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
### VNC Customisation
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    NO_VNC_HOME=/headless/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION="1600x1200" \
    VNC_PASSWORD=${VNC_PASSWORD} \
    VNC_VIEW_ONLY=false \
    ROS_VERSION=${ROS_VERSION} \
    ROS_MASTER=${ROS_MASTER} \
    ROS_MASTER_PORT=${ROS_MASTER_PORT} \
    ROS_DISTRO=noetic

EXPOSE $VNC_PORT $NO_VNC_PORT

### Environment config
ENV HOME=${USER_HOME} \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    DEBIAN_FRONTEND=noninteractive \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

WORKDIR ${HOME}

USER root

### Add all install scripts for further steps
COPY files/common/install/ files/ubuntu/install/ $INST_SCRIPTS/
COPY files/common/scripts $STARTUPDIR

COPY files/ubuntu/icewm/ files/home $HOME/

COPY files/bin /usr/local/bin/
COPY files/movai-entrypoint.sh /usr/local/bin/

### Install some common tools
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} + && \
    $INST_SCRIPTS/tools.sh && \
    ### Install custom fonts
    $INST_SCRIPTS/install_custom_fonts.sh
### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh && \
    $INST_SCRIPTS/no_vnc.sh

### Install IceWM UI
RUN $INST_SCRIPTS/icewm_ui.sh

### Install Foxglove
RUN $INST_SCRIPTS/foxglove.sh

### Install ROS1 tools
ENV ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"
RUN $INST_SCRIPTS/ros-tools.sh && \
    $INST_SCRIPTS/rqt.sh && \
    ### Clean
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ### configure startup
    $INST_SCRIPTS/libnss_wrapper.sh && \
    $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR ${HOME} && \
    chown -R movai:movai ${HOME} && \
    # Clean apt
    apt-get autoremove -y && \
    apt-get clean -y > /dev/null && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*

### Overwritting Rviz config
RUN mkdir -p ~/.rviz
COPY --chown=movai:movai files/home/default.rviz ~/.rviz/default.rviz

USER movai
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--wait"]
