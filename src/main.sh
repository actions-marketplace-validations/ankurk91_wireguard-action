#!/usr/bin/env bash
# Install WireGuard and bring up the tunnel.
set -euo pipefail

WG_INTERFACE="${INPUT_INTERFACE:-wg0}"
WG_CONF_PATH="/etc/wireguard/${WG_INTERFACE}.conf"

if [ -z "${INPUT_CONFIG:-}" ]; then
  echo "::error::input 'config' is empty"
  exit 1
fi

public_ip() {
  curl -4 -s --connect-timeout 5 --max-time 10 https://api.ipify.org || echo 'unavailable'
}

echo "Public IP before VPN: $(public_ip)"

echo "=== Installing wireguard-tools ==="
if command -v wg-quick > /dev/null; then
  echo "already installed, skipping"
else
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    --no-install-recommends \
    -o Dpkg::Use-Pty=0 \
    -o Dpkg::Options::=--force-unsafe-io \
    wireguard-tools
fi

echo "=== Writing $WG_CONF_PATH ==="
sudo mkdir -p /etc/wireguard
printf '%s\n' "$INPUT_CONFIG" | sudo tee "$WG_CONF_PATH" > /dev/null
sudo chmod 600 "$WG_CONF_PATH"

echo "=== Starting $WG_INTERFACE ==="
sudo wg-quick up "$WG_INTERFACE"

echo "=== WireGuard ==="
sudo wg show

echo
echo "=== $WG_INTERFACE IP address ==="
ip -4 addr show "$WG_INTERFACE"

echo
echo "=== Routes ==="
ip route

echo
echo "Public IP after VPN: $(public_ip)"
