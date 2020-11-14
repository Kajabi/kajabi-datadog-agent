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

mkdir -p "$DD_CONF_DIR/conf.d/$DEPLOY.d"

RFC3339='([0-9]+)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(\.[0-9]+)?(([Zz])|([\+|\-]([01][0-9]|2[0-3]):[0-5][0-9]))'
echo "
logs:
  - type: tcp
    port: 10518
    service: $DEPLOY
    source: heroku
    log_processing_rules:
      - type: multi_line
        name: new_log_start_with_date
        pattern: $RFC3339
" >> "$DD_CONF_DIR/conf.d/$DEPLOY.d/conf.yaml"
