# Troubleshooting

## `resolvconf: command not found`

Your config has a `DNS =` line, and `wg-quick` needs a `resolvconf` implementation to apply
it. Either drop the `DNS =` line, or install one before connecting:

```yaml
- run: sudo apt-get install -y openresolv
```

## `Cannot find device "wg0"` / `RTNETLINK answers: Operation not supported`

The runner's kernel has no WireGuard module. GitHub-hosted Ubuntu runners do; if you hit
this on a self-hosted runner or inside a container, install the `wireguard` kernel module
package on the host.

## `Address already in use` / `wg0 already exists`

An earlier run left the interface up. This only happens on self-hosted runners, since
GitHub-hosted runners are destroyed after every job. Run `sudo wg-quick down wg0` on the
runner to clear it.

## Public IP didn't change

Your config's `AllowedIPs` doesn't cover the traffic. Use `AllowedIPs = 0.0.0.0/0` to route
everything through the tunnel; a narrower range only routes those destinations.

## The job hangs after connecting

`AllowedIPs = 0.0.0.0/0` also routes the runner's connection to GitHub through the VPN. If
your VPN blocks that, narrow `AllowedIPs` to just the hosts you need to reach.

## `Warning: /etc/wireguard/wg0.conf is world accessible`

Harmless — the action sets mode `600` before starting the tunnel, so you should not see
this. If you do, something else wrote the file.

## `the tunnel is up but never handshaked with the peer`

The interface came up but no packet ever made it to the peer and back, so the tunnel is not
carrying traffic. `wg-quick` cannot detect this on its own — it reports success as soon as
the interface exists. Check that:

- `Endpoint` is correct and its UDP port is reachable from the runner
- the server has this client's public key in its peer list
- `PresharedKey` matches on both sides, if you use one

This check only runs for full tunnels (`AllowedIPs = 0.0.0.0/0`).

## Handshake never completes (`latest handshake` stays empty)

Check `Endpoint` is reachable from the runner and that the port is UDP-open, and that the
server has this client's public key in its peer list.

## `Error: IPv6 is disabled` / `Address family not supported by protocol`

Your config has IPv6 settings and the runner has no IPv6 connectivity. Remove the IPv6
`Address`, `AllowedIPs` (`::/0`), and `DNS` entries — see the requirements in the README.

## `404 Not Found` when fetching the wireguard-tools package

This action does not run `apt-get update`, to keep it fast — it installs from the apt
indexes already on the runner image. Those indexes are as of the image build, so in rare
cases a package version they list is no longer in the archive. If that happens, add a step
before this action:

```yaml
- run: sudo apt-get update
```
