#!/usr/bin/env bash
set -e

HOME_DIR=${1:-${HOME}}
ROS_VERSION_ARG=${2:-${ROS_VERSION}}

MENU_FILE="${HOME_DIR}/.icewm/menu"
TOOLBAR_FILE="${HOME_DIR}/.icewm/toolbar"

if [[ ! -f "${MENU_FILE}" ]]; then
    echo "Error: Missing IceWM menu file: ${MENU_FILE}" >&2
    exit 1
fi

if [[ ! -f "${TOOLBAR_FILE}" ]]; then
    echo "Error: Missing IceWM toolbar file: ${TOOLBAR_FILE}" >&2
    exit 1
fi

if [[ "${ROS_VERSION_ARG}" != "noetic" ]]; then
    sed -i '/^prog "Lichtblick" /d; /^prog "RViz" /d' "${MENU_FILE}"
    sed -i '/^prog Lichtblick /d; /^prog RViz /d' "${TOOLBAR_FILE}"
fi

envsubst < "${MENU_FILE}" > /tmp/.icewm-menu
envsubst < "${TOOLBAR_FILE}" > /tmp/.icewm-toolbar
mv /tmp/.icewm-menu "${MENU_FILE}"
mv /tmp/.icewm-toolbar "${TOOLBAR_FILE}"
