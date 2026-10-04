#!/bin/sh
# Route kubefwd's 127.1.0.0/8 loopback aliases (bound on the Windows host)
# through WSL mirrored-mode's loopback0 bridge so they are reachable inside WSL.
set -e

GW=""
i=0
while [ "$i" -lt 60 ]; do
    GW=$(ip -4 route show table 127 2>/dev/null | awk '$1=="127.0.0.1" && $2=="via" {print $3; exit}')
    [ -n "$GW" ] && break
    i=$((i + 1))
    sleep 1
done

if [ -z "$GW" ]; then
    echo "wsl-kubefwd-route: loopback0 gateway not found" >&2
    exit 1
fi

ip route del local 127.0.0.0/16 dev lo table 127 2>/dev/null || true
ip route add local 127.0.0.0/16 dev lo table 127 2>/dev/null || true
ip route replace 127.0.0.0/8 via "$GW" dev loopback0 src 127.0.0.1 onlink table 127
echo "wsl-kubefwd-route: forwarded 127.0.0.0/8 to Windows via $GW"
