# This Dockerfile is used to build an headless vnc image based on Ubuntu
ARG DOCKER_REGISTRY="registry.cloud.mov.ai"
FROM ${DOCKER_REGISTRY}/devops/movai-base-melodic:v1.4.5

LABEL description="MOV.AI Graphical Tools"
LABEL maintainer="devop@mov.ai"
LABEL movai="ros-tools"
LABEL environment="develop"

ARG USER_ID=1000
ARG USER_NAME=movai
ARG USER_HOME=/headless
ARG ROS_VERSION="melodic"
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
    ROS_DISTRO=melodic

### Environment config
ENV HOME=${USER_HOME} \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    DEBIAN_FRONTEND=noninteractive \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### ROS Config
ENV ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"

WORKDIR ${HOME}

### Add all install scripts for further steps
COPY files/common/install/ files/ubuntu/install/ $INST_SCRIPTS/
COPY files/ubuntu/icewm/ files/home $HOME/
COPY files/common/scripts $STARTUPDIR
COPY files/bin /usr/local/bin/

RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} + && \
    ### Install some common tools
    $INST_SCRIPTS/tools.sh && \
    ### Install custom fonts
    $INST_SCRIPTS/install_custom_fonts.sh && \
    ### Install xvnc-server & noVNC - HTML5 based VNC viewer
    $INST_SCRIPTS/tigervnc.sh && \
    $INST_SCRIPTS/no_vnc.sh && \
    ### Install IceWM UI
    $INST_SCRIPTS/icewm_ui.sh && \
    ### Install ROS1 Melodic tools
    $INST_SCRIPTS/ros-tools.sh && \
    ### Clean
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ### configure startup
    $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR ${HOME} && \
    chown -R movai:movai ${HOME}

### Overwritting Rviz config
COPY --chown=movai:movai files/home/default.rviz /opt/ros/${ROS_VERSION}/share/rviz/default.rviz

USER movai
ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
