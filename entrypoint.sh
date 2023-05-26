#!/bin/sh

if [ "$ROLE" = "peer" ]; then
    exec /app/start-peer.sh
elif [ "$ROLE" = "seed" ]; then
    exec /app/start-seed.sh
else
    echo "No or invalid role specified"
    exit 1
fi
