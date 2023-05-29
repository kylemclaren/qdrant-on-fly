#!/bin/sh

TAILSCALE_HOSTNAME="qdrant-peer-${FLY_ALLOC_ID}-${FLY_REGION}"

# Start Tailscale in the background.
/app/tailscaled --state=mem: --socket=/var/run/tailscale/tailscaled.sock &

sleep 2

# Now bring up Tailscale.
/app/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${TAILSCALE_HOSTNAME}"

sleep 5

# Check for any active devices starting with "qdrant".
FIRST_PEER=$(/app/tailscale status --json | jq -r '.Peer | to_entries[] | select(.value.DNSName | startswith("qdrant-peer")) | select(.value.Online == true) | .value.DNSName' | head -1)

echo "FIRST_PEER: ${FIRST_PEER}"

if [ -n "$FIRST_PEER" ]; then
    # If there are other active devices, use the HostName of one of them.
    echo "Starting with bootstrap: http://${FIRST_PEER}:6335"
    ./qdrant --bootstrap "http://${FIRST_PEER}:6335" --uri "http://${TAILSCALE_HOSTNAME}.${TAILNET_DOMAIN}:6335"
else
    # If there are no other active devices, start normally.
    echo "Starting without bootstrap"
    ./qdrant --uri "http://${TAILSCALE_HOSTNAME}.${TAILNET_DOMAIN}:6335"
fi
