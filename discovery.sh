#!/bin/bash

function get_containers_by_service() {
  local service=$1
  curl -s --unix-socket /tmp/docker.sock http://localhost/containers/json | \
    jq "map(select(.Labels.\"com.docker.compose.service\" == \"${service}\" and .Labels.\"com.docker.compose.oneoff\" == \"False\"))"
}

function get_kafka_bootstrap_server() {
  get_containers_by_service "kafka" | \
    jq -r ".[0].NetworkSettings.Networks | .[].IPAddress | select (. != null)"
}

apk add --no-cache curl jq

export KAFKA_BOOTSTRAP_SERVER=$(get_kafka_bootstrap_server):${KAFKA_PORT}

exec /docker-entrypoint.sh "$@"
