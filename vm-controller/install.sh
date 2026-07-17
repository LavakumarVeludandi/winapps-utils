#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/winapps-utils"
CONFIG_FILE="$CONFIG_DIR/vm-controller.conf"
APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/winapps-vm-controller.desktop"

echo "Installing Windows VM Controller..."

missing=()
for cmd in zenity notify-send docker; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "Warning: missing dependencies: ${missing[*]}"
    echo "  e.g. sudo apt install zenity libnotify-bin docker-compose-plugin"
fi

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$APPS_DIR"

cp "$SCRIPT_DIR/vm_control.sh" "$BIN_DIR/winapps-vm-control.sh"
chmod +x "$BIN_DIR/winapps-vm-control.sh"

if [ -f "$CONFIG_FILE" ]; then
    echo "Existing config found at $CONFIG_FILE, keeping it."
else
    CANDIDATES=(
        "$HOME/winapps/compose.yaml"
        "$HOME/.config/winapps/compose.yaml"
        "/opt/winapps/compose.yaml"
    )
    FOUND=""
    for c in "${CANDIDATES[@]}"; do
        if [ -f "$c" ]; then
            FOUND="$c"
            break
        fi
    done

    if [ -n "$FOUND" ]; then
        COMPOSE_PATH="$FOUND"
        echo "Detected compose file: $COMPOSE_PATH"
    else
        read -r -p "Enter the full path to your winapps compose.yaml: " COMPOSE_PATH
    fi
    printf 'WINAPPS_COMPOSE_FILE="%s"\n' "$COMPOSE_PATH" > "$CONFIG_FILE"
    echo "Saved config to $CONFIG_FILE"
fi

sed "s|__EXEC_PATH__|$BIN_DIR/winapps-vm-control.sh|" \
    "$SCRIPT_DIR/windows-vm-controller.desktop.template" > "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE"
command -v gio >/dev/null 2>&1 && gio set "$DESKTOP_FILE" "metadata::trusted" true 2>/dev/null || true

if [ -d "$HOME/Desktop" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/winapps-vm-controller.desktop"
    chmod +x "$HOME/Desktop/winapps-vm-controller.desktop"
    command -v gio >/dev/null 2>&1 && gio set "$HOME/Desktop/winapps-vm-controller.desktop" "metadata::trusted" true 2>/dev/null || true
fi

echo "Done. Find 'Windows VM Controller' in your applications menu, or on the Desktop."
echo "If the Desktop icon shows as untrusted, right-click it and choose 'Allow Launching'."
