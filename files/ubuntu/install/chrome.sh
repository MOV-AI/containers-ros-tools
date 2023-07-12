#!/bin/bash

export CHROMIUM_VERSION=85.0.4183.83-0ubuntu2
export CHROMIUM_DISTRO=amd64

mkdir -p /tmp/chromium

wget --show-progress --progress=bar:force:noscroll \
    -q http://archive.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_"${CHROMIUM_VERSION}"_"${CHROMIUM_DISTRO}".deb \
    -P /tmp/chromium

wget --show-progress --progress=bar:force:noscroll \
    -q http://archive.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg_"${CHROMIUM_VERSION}"_"${CHROMIUM_DISTRO}".deb \
    -P /tmp/chromium

wget --show-progress --progress=bar:force:noscroll \
    -q http://archive.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser-l10n_"${CHROMIUM_VERSION}"_all.deb \
    -P /tmp/chromium

DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
    /tmp/chromium/chromium-codecs-ffmpeg_"${CHROMIUM_VERSION}"_"${CHROMIUM_DISTRO}".deb \
    /tmp/chromium/chromium-browser_"${CHROMIUM_VERSION}"_"${CHROMIUM_DISTRO}".deb \
    /tmp/chromium/chromium-browser-l10n_"${CHROMIUM_VERSION}"_all.deb \


echo -e "#!/bin/bash\n chromium --no-sandbox --disable-gpu --user-data-dir --window-size=${VNC_RESOLUTION%x*},${VNC_RESOLUTION#*x} --window-position=0,0\n" > /usr/bin/chromium-browser
ln -sfn /usr/bin/chromium /usr/bin/chromium-browser
chmod +x /usr/bin/chromium-browser
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

rm -rf /tmp/chromium