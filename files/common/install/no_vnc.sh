#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u

NO_VNC_VERSION=${NO_VNC_VERSION:-v1.7.0}
WEBSOCKIFY_VERSION=${WEBSOCKIFY_VERSION:-v0.13.0}

echo "Install noVNC - HTML5 based VNC viewer"
mkdir -p $NO_VNC_HOME/utils/websockify
wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/$NO_VNC_VERSION.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME
wget -qO- https://github.com/novnc/websockify/archive/refs/tags/$WEBSOCKIFY_VERSION.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify
#chmod +x -v $NO_VNC_HOME/utils/*.sh
## create index.html to forward automatically to `vnc_lite.html`
ln -s $NO_VNC_HOME/vnc.html $NO_VNC_HOME/index.html
