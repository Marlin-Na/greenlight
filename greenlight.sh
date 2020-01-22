#!/usr/bin/env bash

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
    (ssh $GREENLT_SERVER bash <<'EOF'
    mkdir -p /tmp/greenlight
    ls -At /tmp/greenlight | while read alias; do
      port=`tail -n 1 /tmp/greenlight/$alias`
      user=`head -n 1 /tmp/greenlight/$alias`
      echo "$alias  $user  $port"
    done
EOF
) | awk -v host=$GREENLT_SERVER '{ print "    ssh -J " host " " $2 "@localhost -p " $3 "[] # " $1}' | column -t -s "[]"
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
        echo $GREENLT_CLIENT_USER > /tmp/greenlight/$GREENLT_CLIENT_ALIAS
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
    echo
    echo Available sessions on $GREENLT_SERVER:
    echo
    query_session
    echo
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
