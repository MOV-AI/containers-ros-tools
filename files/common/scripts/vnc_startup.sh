#!/bin/bash
VERBOSE=${VERBOSE:-false}
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

log_gpu_context() {
    log_info "GPU context summary"
    log_info "DISPLAY=${DISPLAY:-unset}"
    log_info "RENDER_BACKEND=${RENDER_BACKEND:-default}"
    log_info "VGL_DISPLAY=${VGL_DISPLAY:-unset}"
    log_info "NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-unset}"
    log_info "NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-unset}"
    log_info "LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-unset}"

    if command -v vglrun >/dev/null 2>&1; then
        log_info "VirtualGL launcher is available: $(command -v vglrun)"
    else
        log_info "VirtualGL launcher is not installed"
    fi

    if [ -d /dev/dri ]; then
        log_info "/dev/dri is present"
        ls -l /dev/dri 2>/dev/null | sed 's/^/    /' || true
    else
        log_warn "/dev/dri is not present (Intel/DRI acceleration unavailable)"
    fi

    if compgen -G "/dev/nvidia*" >/dev/null; then
        log_info "NVIDIA device nodes are present"
        ls -l /dev/nvidia* 2>/dev/null | sed 's/^/    /' || true
    else
        log_info "NVIDIA device nodes are not present"
    fi

    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia_smi_output=""
        if nvidia_smi_output="$(nvidia-smi -L 2>/dev/null)"; then
            printf '%s\n' "$nvidia_smi_output" | sed 's/^/    /'
        else
            log_warn "nvidia-smi is installed but could not query GPUs"
        fi
    else
        log_info "nvidia-smi is not installed in this image"
    fi
}

resolve_vnc_password_binary() {
    if command -v vncpasswd >/dev/null 2>&1; then
        echo "vncpasswd"
        return 0
    fi

    if command -v tigervncpasswd >/dev/null 2>&1; then
        echo "tigervncpasswd"
        return 0
    fi

    return 1
}

is_vnc_running() {
    local display_with_colon display_without_colon
    local vnc_list_output
    display_with_colon="$DISPLAY"
    display_without_colon="${DISPLAY#:}"

    vnc_list_output="$(vncserver -list 2>&1 || true)"

    if awk -v d1="$display_with_colon" -v d2="$display_without_colon" '$1 == d1 || $1 == d2 { found=1 } END { exit !found }' <<< "$vnc_list_output"; then
        return 0
    fi

    if [[ $VERBOSE == "true" ]]; then
        log_debug "vncserver -list output when no session matched DISPLAY=$DISPLAY:\n$vnc_list_output"
    fi

    return 1
}

cleanup_stale_files() {
    log_info "Performing cleanup of stale VNC/X11 files..."

    # Remove stale X11 lock and socket files
    for lockfile in /tmp/.X*-lock /tmp/.X11-unix/X*; do
        if [ -e "$lockfile" ]; then
            log_info "Removing lock file: $lockfile"
            rm -f "$lockfile"
        fi
    done
    rm -f /tmp/.X11-unix/X*

    # Reset VNC password file
    if [ -f "$HOME/.vnc/passwd" ]; then
        log_info "Removing VNC password file..."
        rm -f "$HOME/.vnc/passwd"
    fi

    # Remove old VNC PID files
    rm -f "$HOME/.vnc/"*.pid
    log_info "Cleanup complete."
}

## cleanup function
cleanup () {
    log_info "Cleaning up VNC session..."

    # Kill noVNC proxy process if running
    if [ -n "$PID_SUB" ] && ps -p $PID_SUB > /dev/null; then
        log_info "Terminating noVNC proxy process..."
        kill -TERM $PID_SUB 2>/dev/null || true
    fi

    # Kill VNC server for current display
    if [ -n "$DISPLAY" ]; then
        log_info "Terminating VNC server on display $DISPLAY..."
        vncserver -kill $DISPLAY >/dev/null 2>&1 || true
    fi

    # Clean up stale files
    cleanup_stale_files

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
if [[ $VERBOSE == "true" ]]; then
    log_gpu_context
fi

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

## cleanup potential relicates of previous runs
cleanup_stale_files

## set password
PASSWD_PATH="$HOME/.vnc/passwd"
if ! VNC_PASSWD_BIN="$(resolve_vnc_password_binary)"; then
    log_error "No VNC password utility found. Install TigerVNC tools (expected vncpasswd or tigervncpasswd)."
    exit 1
fi

if [[ $VNC_VIEW_ONLY == "true" ]]; then
    log_info "Starting VNC server in VIEW ONLY mode!"
    #create random pw to prevent access
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 | "$VNC_PASSWD_BIN" -f > "$PASSWD_PATH"
fi
echo "$VNC_PASSWORD" | "$VNC_PASSWD_BIN" -f >> "$PASSWD_PATH"
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

# Function to handle service output
handle_output() {
    local prefix=$1
    local logfile=$2
    if [[ $VERBOSE == "true" ]]; then
        sed "s/^/[$prefix] /"
    else
        tee -a "$logfile"
    fi
}

# Start noVNC with appropriate output handling
log_info "Starting noVNC web client..."
if [[ $VERBOSE == "true" ]]; then
    "$NO_VNC_HOME"/utils/novnc_proxy --vnc localhost:"$VNC_PORT" --listen "$NO_VNC_PORT" 2>&1 | handle_output "noVNC" "$NOVNC_LOG" &
else
    "$NO_VNC_HOME"/utils/novnc_proxy --vnc localhost:"$VNC_PORT" --listen "$NO_VNC_PORT" > "$NOVNC_LOG" 2>&1 &
fi
PID_SUB=$!
log_debug "noVNC started with PID $PID_SUB"

## start VNC server
log_info "Starting VNC server..."

# Create necessary directories
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

log_info "Starting vncserver with params: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION"

vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
if [[ ${VNC_PASSWORDLESS:-} == "true" ]]; then
    vnc_cmd="${vnc_cmd} -SecurityTypes None"
fi

log_debug "VNC command: $vnc_cmd"

## Start VNC server with appropriate output handling
if [[ $VERBOSE == "true" ]]; then
    eval "$vnc_cmd" 2>&1 | handle_output "VNC" "$VNC_LOG" || {
        log_error "Failed to start VNC server"
        exit 1
    }
else
    if ! eval "$vnc_cmd" > "$VNC_LOG" 2>&1; then
        log_error "Failed to start VNC server. Check logs at $VNC_LOG"
        exit 1
    fi
fi

log_info "Starting window manager..."
if [[ $VERBOSE == "true" ]]; then
    $HOME/wm_startup.sh 2>&1 | handle_output "WM" "$WM_LOG" &
else
    $HOME/wm_startup.sh > "$WM_LOG" 2>&1 &
fi

## log connect options
log_info "------------------ VNC environment started ------------------"
log_info "VNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
log_info "noVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/\n"

# In non-verbose mode, show how to access logs
if [[ $VERBOSE != "true" ]]; then
    log_info "To see the logs, run: tail -f $VNC_LOG $NOVNC_LOG $WM_LOG"
fi
echo "----"

if $WAIT || [ -z "$1" ]; then
    # Set up signal handlers
    trap cleanup SIGINT SIGTERM SIGHUP

    # Wait for noVNC proxy and monitor VNC server
    while true; do
        if ! ps -p $PID_SUB >/dev/null 2>&1; then
            log_error "noVNC proxy process died, restarting..."
            "$NO_VNC_HOME"/utils/novnc_proxy --vnc localhost:"$VNC_PORT" --listen "$NO_VNC_PORT" > "$NOVNC_LOG" 2>&1 &
            PID_SUB=$!
        fi

        # Check if VNC server is running
        if ! is_vnc_running; then
            log_error "VNC server not running, restarting..."

            # Keep monitor loop alive under set -e if restart fails.
            # shellcheck disable=SC2206
            vnc_cmd_argv=($vnc_cmd)
            if ! "${vnc_cmd_argv[@]}" > "$VNC_LOG" 2>&1; then
                log_error "VNC restart failed. Keeping monitor loop alive. Check $VNC_LOG"
            fi
        fi

        sleep 5
    done
else
    # unknown option ==> call command
    log_info "Executing command:" "$@"
    exec "$@"
fi
