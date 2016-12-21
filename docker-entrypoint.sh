#!/bin/bash

set -e

if [ "$1" = 'start-kafka.sh' -a "$(id -u)" = '0' ]; then
    chown -R kafka:kafka /data /logs
    exec su-exec kafka "$0" "$@"
fi

exec "$@"
