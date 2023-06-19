#! /bin/bash
set -euo pipefail

this_host=$(getent ahostsv6 fly-local-6pn | head -1 | cut -d ' ' -f1)
seed=

for i in $(dig +short aaaa $FLY_APP_NAME.internal)
do
    if [[ "$i" != "$this_host" ]]; then
	seed=$i
	break
    fi
done

if [[ "$seed" != "" ]]; then
    # If there are other active devices, use the HostName of one of them.
    echo "Starting with bootstrap..."
    ./qdrant --bootstrap "http://[${seed}]:6335" --uri "http://[${this_host}]:6335"
else
    # If there are no other active devices, start normally.
    echo "Starting without bootstrap"
    ./qdrant --uri "http://[${this_host}]:6335"
fi
