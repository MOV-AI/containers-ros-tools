# This Dockerfile is used to build an headless vnc image based on Ubuntu
ARG DOCKER_REGISTRY="pubregistry.aws.cloud.mov.ai"
FROM ${DOCKER_REGISTRY}/ce/movai-base-focal:v2.5.0

LABEL description="MOV.AI Graphical Tools"
LABEL maintainer="devops@mov.ai"
LABEL movai="ros-tools"
LABEL environment="develop"

ARG USER_ID=1000
ARG USER_NAME=movai
ARG USER_HOME=/headless
ARG ROS_VERSION="noetic"
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

USER root

### Add all install scripts for further steps
COPY files/common/install/ files/ubuntu/install/ $INST_SCRIPTS/
COPY files/ubuntu/icewm/ files/home $HOME/
COPY files/bin /usr/local/bin/

### Install some common tools
WORKDIR ${INST_SCRIPTS}
RUN find ./ -name '*.sh' -exec chmod a+x {} + && \
    ./tools.sh && \
    ### Install custom fonts
    ./install_custom_fonts.sh && \
    ### Install xvnc-server & noVNC - HTML5 based VNC viewer
    ./tigervnc.sh && \
    ./no_vnc.sh && \
    ### Install IceWM UI
    ./icewm_ui.sh && \
    ### Install Lichtblick
    ./lichtblick.sh && \
    ### Install ROS1 tools
    ./ros-tools.sh && \
    ./rqt.sh && \
    ### Clean
    apt-get autoremove -y && \
    apt-get clean -y > /dev/null && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*


### configure startup
COPY files/movai-entrypoint.sh files/docker-entrypoint.sh /usr/local/bin/
COPY files/common/scripts $STARTUPDIR
RUN ./libnss_wrapper.sh && \
    ./set_user_permission.sh $STARTUPDIR ${HOME} && \
    chown -R movai:movai ${HOME} && \
    ### Overwritting Rviz config
    mkdir -p ~/.rviz

COPY --chown=movai:movai files/home/default.rviz ~/.rviz/default.rviz

USER movai

ENV ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"

### Validate required files
RUN if [ ! -f "$INST_SCRIPTS/tools.sh" ]; then \
        echo "Error: Missing required script 'tools.sh' in $INST_SCRIPTS."; \
        exit 1; \
    fi

### Improve health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${NO_VNC_PORT}/ || \
        echo "Error: noVNC is not responding on port ${NO_VNC_PORT}" && exit 1


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--wait"]
