#!/bin/bash
## every exit != 0 fails the script
set -e

## print out help
help (){
    echo "
USAGE:
docker run -it -p 6901:6901 -p 5901:5901 ros-tools:<tag> <option>

OPTIONS:
-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received
-s, --skip      skip the vnc startup and just execute the assigned command.
                example: docker run consol/rocky-xfce-vnc --skip bash
-v, --verbose     enables more detailed startup output
                e.g. 'docker run consol/rocky-xfce-vnc --verbose bash'
-h, --help      print out this help

Fore more information see: https://github.com/ConSol/docker-headless-vnc-container
"
}

## Define log levels and colors
LOG_INFO="\033[0;34m[INFO]\033[0m"
LOG_WARN="\033[0;33m[WARN]\033[0m"
LOG_ERROR="\033[0;31m[ERROR]\033[0m"
LOG_DEBUG="\033[0;32m[DEBUG]\033[0m"

# Helper logging functions
log_info() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") $LOG_INFO $*"
}

log_warn() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") $LOG_WARN $*" >&2
}

log_error() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") $LOG_ERROR $*" >&2
}

log_debug() {
    if [ "${VERBOSE:-false}" = "true" ]; then
        echo -e "$(date +"%Y-%m-%d %H:%M:%S") $LOG_DEBUG $*"
    fi
}

## cleanup function
cleanup () {
    log_info "Cleaning up..."
    kill -s SIGTERM $!
    exit 0
}

## Parse options
VERBOSE=false
SKIP=false
WAIT=false

for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            log_info "Verbose mode enabled."
            export VERBOSE
            ;;
        -s|--skip)
            SKIP=true
            ;;
        -w|--wait)
            WAIT=true
            ;;
        *)
            # Ignore unknown options for now
            ;;
    esac
done

## Validate conflicting options
if $SKIP && $WAIT; then
    log_error "Options --skip and --wait cannot be used together."
    exit 1
fi

## Validate required environment variables
if [[ -z "$VNC_PASSWORD" ]]; then
    log_error "VNC_PASSWORD environment variable is not set."
    exit 1
fi

if [[ -z "$VNC_PORT" || -z "$NO_VNC_PORT" ]]; then
    log_error "Please set VNC_PORT and NO_VNC_PORT in your environment."
    exit 1
fi

# should also source $STARTUPDIR/generate_container_user
source $HOME/.bashrc

if $SKIP; then
    log_info "Skipping VNC startup, executing command:" "${@:2}"
    echo "Executing command:" "${@:2}"
    exec "${@:2}"
fi

## correct forwarding of shutdown signal
trap cleanup SIGINT SIGTERM

## resolve_vnc_connection
VNC_IP=$(hostname -i || echo "127.0.0.1")
mkdir -p "$HOME/.vnc"

PASSWD_PATH="$HOME/.vnc/passwd"
if [[ -f $PASSWD_PATH ]]; then
    log_info "Removing old VNC password file: $PASSWD_PATH"
    rm -f "$PASSWD_PATH"
fi

if [[ $VNC_VIEW_ONLY == "true" ]]; then
    log_info "Starting VNC server in VIEW ONLY mode!"
    #create random pw to prevent access
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 | vncpasswd -f > "$PASSWD_PATH"
fi
echo "$VNC_PASSWORD" | vncpasswd -f >> "$PASSWD_PATH"
chmod 600 "$PASSWD_PATH"
log_info "VNC password file created at $PASSWD_PATH"

## start noVNC webclient
log_info "Starting noVNC web client..."
log_info "with options:VNC_IP=$VNC_IP, VNC_PORT=$VNC_PORT, NO_VNC_PORT=$NO_VNC_PORT"
mkdir -p "$STARTUPDIR"/logs

# Use fixed log file names instead of timestamps
NOVNC_LOG="$STARTUPDIR/logs/novnc.log"
VNC_LOG="$STARTUPDIR/logs/vnc.log"
WM_LOG="$STARTUPDIR/logs/windowmanager.log"

# Start noVNC with standardized logging
"$NO_VNC_HOME"/utils/novnc_proxy --vnc localhost:"$VNC_PORT" --listen "$NO_VNC_PORT" > "$NOVNC_LOG" 2>&1 &
PID_SUB=$!
log_debug "noVNC started with PID $PID_SUB"

## start VNC server
log_info "Starting VNC server..."
vncserver -kill $DISPLAY &> "$VNC_LOG" \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> "$VNC_LOG" \
    || log_warn "No locks present"

log_info "Starting vncserver with params: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION"

vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
if [[ ${VNC_PASSWORDLESS:-} == "true" ]]; then
  vnc_cmd="${vnc_cmd} -SecurityTypes None"
fi

log_debug "VNC command: $vnc_cmd"

## Add error handling for VNC server startup
if ! $vnc_cmd > "$VNC_LOG" 2>&1; then
    log_error "Failed to start VNC server. Check logs at $VNC_LOG"
    exit 1
fi

log_info "Starting window manager..."
$HOME/wm_startup.sh > "$WM_LOG" 2>&1 &

## log connect options
log_info "------------------ VNC environment started ------------------"
log_info "VNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
log_info "noVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"

if [[ $VERBOSE == "true" ]]; then
    log_debug "Tailing log files from VNC, noVNC, and window manager"
    echo "----"
    tail -f "$VNC_LOG" "$NOVNC_LOG" "$WM_LOG" | grep -v "Connection reset by peer" &
else
    log_info "To see the logs, run: tail -f $VNC_LOG $NOVNC_LOG $WM_LOG"
    echo "----"
fi

if $WAIT || [ -z "$1" ]; then
    wait $PID_SUB
else
    # unknown option ==> call command
    log_info "Executing command:" "$@"
    exec "$@"
fi
