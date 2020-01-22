#!/usr/bin/env bash

## The sshd_config on the server needs to set Gatewayports to 'yes'
## There are also alternative ways without requiring config on the server.
## Check https://superuser.com/a/1107557 and https://superuser.com/a/1444518

set -e

GREENLT_CLIENT_USER="$USER"
GREENLT_CLIENT_HOST=`hostname`

if [ -z "$GREENLT_CLIENT_ALIAS" ]; then
    GREENLT_CLIENT_ALIAS=$GREENLT_CLIENT_HOST
fi

if [ -z "$GREENLT_SERVER" ]; then
    echo Missing 'GREENLT_SERVER' environment variable
    echo It should be in the format of 'user@address:port'
    exit 1
fi

function query_session {
    echo Available sessions on $GREENLT_SERVER:
    ssh $GREENLT_SERVER "mkdir -p /tmp/greenlight && ls -tl /tmp/greenlight" | \
        awk '{ print $9 "\t" $6 "-" $7 }' | column -t
}

function host_session {
    # Get available port on remote server https://unix.stackexchange.com/a/423052/168574
    remote_port=$(
    ssh -T $GREENLT_SERVER bash <<'EOF'
    comm -23 <(seq 49152 65535 | sort) <(ss -tan | awk '{print $4}' | cut -d':' -f2 | grep "[0-9]\{1,5\}" | sort -u) | shuf | head -n 1
EOF
)
    ssh -T -R $remote_port:localhost:22 $GREENLT_SERVER bash <<EOF
        set -e
        mkdir -p /tmp/greenlight
        touch /tmp/greenlight/$GREENLT_CLIENT_ALIAS
        echo $GREENLT_CLIENT_USER@$GREENLT_CLIENT_HOST > /tmp/greenlight/$GREENLT_CLIENT_ALIAS
        echo $remote_port >> /tmp/greenlight/$GREENLT_CLIENT_ALIAS
        echo "=== Connection established with $GREENLT_SERVER ==="
        echo "Now you can login your machine with:"
        echo "   ssh -J $GREENLT_SERVER $GREENLT_CLIENT_USER@localhost -p $remote_port"
        while true; do sleep 100; done
EOF
}

function connect_session {
    if [ -z "$1" ]; then
        echo Missing argument 'alias'
        exit 1
    fi
    ssh -J $GREENLT_SERVER $1
}

## Main
if [ "$#" -eq 0 ]; then
    echo "Usage:"
    echo "    $0 host"
    echo "    $0 connect <alias>"
    echo -----------
    query_session
    exit 0
fi

if [ "$1" = host ]; then
    host_session
elif [ "$1" = connect ]; then
    connect_session $2
else
    echo "Invalid command [$1]"
    exit 1
fi
