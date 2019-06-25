#!/usr/bin/env bash

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

# Update the Postgres configuration from above using the Heroku application environment variable
# if [ -n "$DATABASE_URL" ]; then
#   POSTGREGEX='^postgres://([^:]+):([^@]+)@([^:]+):([^/]+)/(.*)$'
#   if [[ $DATABASE_URL =~ $POSTGREGEX ]]; then
#     sed -i "s/<YOUR HOSTNAME>/${BASH_REMATCH[3]}/" "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
#     sed -i "s/<YOUR USERNAME>/${BASH_REMATCH[1]}/" "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
#     sed -i "s/<YOUR PASSWORD>/${BASH_REMATCH[2]}/" "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
#     sed -i "s/<YOUR PORT>/${BASH_REMATCH[4]}/" "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
#     sed -i "s/<YOUR DBNAME>/${BASH_REMATCH[5]}/" "$DD_CONF_DIR/conf.d/postgres.d/conf.yaml"
#   fi
# fi
