# This Dockerfile is used to build an headless vnc image based on Ubuntu

# FROM ros:noetic-ros-core-focal
FROM ubuntu:focal

LABEL description="MOV.AI Graphical Tools"
LABEL maintainer="devop@mov.ai"
LABEL movai="ros-tools"
LABEL environment="develop"

ARG USER_ID=1000
ARG USER_NAME=movai
ARG USER_HOME=/headless
ARG ROS_MASTER="ros-master"
ARG ROS_MASTER_PORT="11311"


### Environment config
ENV HOME=${USER_HOME} \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    DEBIAN_FRONTEND=noninteractive \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### ROS Config
ENV ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"

### Install rviz
RUN apt update && apt install rviz -y

RUN apt autoremove -y

WORKDIR ${HOME}

### Add all install scripts for further steps
COPY files/common/install/ files/ubuntu/install/ $INST_SCRIPTS/
COPY files/common/scripts $STARTUPDIR
COPY files/bin /usr/local/bin/

RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} + && \
    ### Clean
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ### configure startup
    $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR ${HOME} && \
    ### Add movai user
    useradd -ms /bin/bash movai && \
    chown -R movai:movai ${HOME} && \
    # noetic python
    ln -sf /usr/bin/python2 /usr/bin/python

USER movai
ENTRYPOINT ["/usr/local/bin/rviz.sh"]
CMD ["--wait"]
