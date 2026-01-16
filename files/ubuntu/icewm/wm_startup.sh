#!/usr/bin/env bash
echo -e "\n------------------ startup of IceWM window manager ------------------"

### disable screensaver and power management
if xset q | grep -q "DPMS is Enabled"; then
    xset -dpms
else
    echo "Warning: DPMS is not supported by the X server."
fi
xset s noblank
xset s off

### start IceWM session (not needed since IceWM is started by Xvnc-session)
# LOG_FILE="${HOME:-/tmp}/wm.log"
# if ! /usr/bin/icewm-session  > "$LOG_FILE" 2>&1; then
#     echo "Error: Failed to start IceWM session. Log content:"
#     cat "$LOG_FILE"
#     exit 1
# fi
