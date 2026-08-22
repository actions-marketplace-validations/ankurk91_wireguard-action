#!/usr/bin/env bash
# Stop the tunnel and remove its config. Never fails the job.
set -uo pipefail

WG_INTERFACE="${INPUT_INTERFACE:-wg0}"
WG_CONF_PATH="/etc/wireguard/${WG_INTERFACE}.conf"

echo "=== Stopping $WG_INTERFACE ==="

# An invalid name means the main step never got as far as writing a config, so
# there is nothing here to undo. Bail out before rm sees the untrusted path.
if ! [[ $WG_INTERFACE =~ ^[a-zA-Z0-9_=+.-]{1,15}$ ]]; then
  echo "invalid interface name, nothing to clean up"
  exit 0
fi

if command -v wg-quick > /dev/null; then
  sudo wg-quick down "$WG_INTERFACE" || true
else
  echo "wireguard-tools is not installed, nothing to stop"
fi

sudo rm -f "$WG_CONF_PATH"

echo "Wireguard cleanup completed."

exit 0
