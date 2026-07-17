#!/bin/bash
set -euo pipefail

# Per-machine settings (compose file path) live here so this script has no
# hardcoded username/path and can be shared across machines via install.sh.
CONFIG_FILE="$HOME/.config/winapps-utils/vm-controller.conf"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

COMPOSE_FILE="${WINAPPS_COMPOSE_FILE:-$HOME/winapps/compose.yaml}"

if [ ! -f "$COMPOSE_FILE" ]; then
    zenity --error --title="Windows VM Controller" \
        --text="Compose file not found:\n$COMPOSE_FILE\n\nRun install.sh again or edit:\n$CONFIG_FILE"
    exit 1
fi

ACTION=$(zenity --list --width=400 --height=350 \
    --title="Windows VM Management" \
    --text="Select an action for your Windows Virtual Machine:" \
    --column="Action" --column="Description" \
    "Start" "Power on the Windows VM" \
    "Pause" "Temporarily freeze the VM state" \
    "Unpause" "Resume the frozen VM state" \
    "Restart" "Reboot the Windows environment" \
    "Stop" "Gracefully shut down Windows" \
    "Kill" "Force power-off immediately")

if [ -z "$ACTION" ]; then
    exit 0
fi

case $ACTION in
    "Start")
        notify-send "Windows VM" "Starting up..." -i virtualbox
        docker compose --file "$COMPOSE_FILE" start
        notify-send "Windows VM" "System is running." -i virtualbox
        ;;
    "Pause")
        docker compose --file "$COMPOSE_FILE" pause
        notify-send "Windows VM" "System paused." -i virtualbox
        ;;
    "Unpause")
        docker compose --file "$COMPOSE_FILE" unpause
        notify-send "Windows VM" "System resumed." -i virtualbox
        ;;
    "Restart")
        notify-send "Windows VM" "Restarting..." -i virtualbox
        docker compose --file "$COMPOSE_FILE" restart
        notify-send "Windows VM" "Restart complete." -i virtualbox
        ;;
    "Stop")
        notify-send "Windows VM" "Sending graceful shutdown signal..." -i virtualbox
        docker compose --file "$COMPOSE_FILE" stop
        notify-send "Windows VM" "System shut down safely." -i virtualbox
        ;;
    "Kill")
        docker compose --file "$COMPOSE_FILE" kill
        notify-send "Windows VM" "Forced power-off executed." -i virtualbox
        ;;
esac
