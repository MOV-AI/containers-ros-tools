# This Dockerfile is used to build an rviz image based on Ubuntu
ARG DOCKER_REGISTRY="pubregistry.aws.cloud.mov.ai"
FROM ${DOCKER_REGISTRY}/ce/movai-base-focal:v2.4.2

LABEL description="MOV.AI Graphical Tools"
LABEL maintainer="devops@mov.ai"
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
    INST_SCRIPTS=/headless/install \
    DEBIAN_FRONTEND=noninteractive \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### ROS Config
ENV ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"

WORKDIR ${HOME}

### Add all install scripts for further steps
COPY files/common/install/set_user_permission.sh files/ubuntu/install/tools.sh $INST_SCRIPTS/
COPY files/bin /usr/local/bin/

RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} + && \
    ### Install rviz
    apt-get update && \
    apt-get install rviz=1.13.7+dfsg-1build2 -y --no-install-recommends && \
    ### Clean
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ### configure startup
    $INST_SCRIPTS/set_user_permission.sh ${HOME} && \
    ### fix owner
    chown -R movai:movai ${HOME}

USER movai
ENTRYPOINT ["/usr/local/bin/rviz.sh"]
CMD ["--wait"]
