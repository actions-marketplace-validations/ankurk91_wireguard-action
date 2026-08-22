#!/usr/bin/env bash
# Stop the tunnel and remove its config. Never fails the job.
set -uo pipefail

WG_INTERFACE="${INPUT_INTERFACE:-wg0}"
WG_CONF_PATH="/etc/wireguard/${WG_INTERFACE}.conf"

echo "=== Stopping $WG_INTERFACE ==="
sudo wg-quick down "$WG_INTERFACE" || true
sudo rm -f "$WG_CONF_PATH"

exit 0
