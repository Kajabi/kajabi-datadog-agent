#!/usr/bin/env bash

# The Datadog agent (installed via buildpack) runs this script just before launching.

DD_CONF_DIR=${DD_CONF_DIR:-/app/.apt/etc/datadog-agent}

# Disable the Datadog Agent based on dyno type
if [ "$DYNOTYPE" == "run" ]; then
  DISABLE_DATADOG_AGENT="true"
fi

echo "
logs_enabled: true
" >> "$DD_CONF_DIR/datadog.yaml"

mkdir "$DD_CONF_DIR/conf.d/kajabi-production.d"

echo "
logs:
  - type: tcp
    port: 10518
    service: kajabi-production
    source: custom
" >> "$DD_CONF_DIR/conf.d/kajabi-production.d/conf.yaml"
