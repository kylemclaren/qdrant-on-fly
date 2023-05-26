#!/bin/sh

TAILSCALE_HOSTNAME="qdrant-peer-${FLY_ALLOC_ID}-${FLY_REGION}"

/app/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
/app/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${TAILSCALE_HOSTNAME}"

./qdrant --bootstrap "http://qdrant-seed.${TAILNET_DOMAIN}:6335" --uri "http://${TAILSCALE_HOSTNAME}.${TAILNET_DOMAIN}:6335"