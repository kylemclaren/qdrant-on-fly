#!/bin/sh

TAILSCALE_HOSTNAME="qdrant-seed"

/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/app/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${TAILSCALE_HOSTNAME}"

./qdrant --uri "http://${TAILSCALE_HOSTNAME}.${TAILNET_DOMAIN}:6335"