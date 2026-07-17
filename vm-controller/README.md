# VM Controller

A native GUI launcher for managing a [WinApps](https://github.com/winapps-org/winapps) Docker
Windows container: Start, Pause, Unpause, Restart, Stop, or Kill — via a `zenity` menu, with
desktop notifications on state changes.

## Install

```bash
./install.sh
```

This will:

- Copy `vm_control.sh` to `~/.local/bin/winapps-vm-control.sh`
- Detect (or prompt for) your `compose.yaml` path and save it to
  `~/.config/winapps-utils/vm-controller.conf`
- Install a desktop entry to `~/.local/share/applications` and, if present, `~/Desktop`

Requires `zenity`, `libnotify` (`notify-send`), and `docker compose`. On Debian/Ubuntu-based
distros (Zorin, Mint, etc.):

```bash
sudo apt install zenity libnotify-bin docker-compose-plugin
```

## Usage

Launch "Windows VM Controller" from your applications menu or Desktop icon. If the Desktop icon
shows as untrusted, right-click it and choose **Allow Launching**.

## Reconfigure

To point at a different compose file, edit:

```
~/.config/winapps-utils/vm-controller.conf
```
