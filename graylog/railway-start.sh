#!/bin/bash
# Railway wrapper for the official Graylog image.
set -euo pipefail

: "${GRAYLOG_PASSWORD_SECRET:?GRAYLOG_PASSWORD_SECRET must be set (at least 16 characters)}"
: "${GRAYLOG_ROOT_PASSWORD:?GRAYLOG_ROOT_PASSWORD must be set}"
: "${GRAYLOG_MONGODB_URI:?GRAYLOG_MONGODB_URI must be set}"
: "${GRAYLOG_ELASTICSEARCH_HOSTS:?GRAYLOG_ELASTICSEARCH_HOSTS must be set}"

# The admin password comes in plain text from a Railway variable; Graylog wants its SHA-256.
# Changing GRAYLOG_ROOT_PASSWORD and redeploying changes the admin password.
GRAYLOG_ROOT_PASSWORD_SHA2="$(printf '%s' "$GRAYLOG_ROOT_PASSWORD" | sha256sum | cut -d' ' -f1)"
export GRAYLOG_ROOT_PASSWORD_SHA2
unset GRAYLOG_ROOT_PASSWORD

export GRAYLOG_ROOT_USERNAME="${GRAYLOG_ROOT_USERNAME:-admin}"
export GRAYLOG_ROOT_TIMEZONE="${GRAYLOG_ROOT_TIMEZONE:-UTC}"
export GRAYLOG_HTTP_BIND_ADDRESS="${GRAYLOG_HTTP_BIND_ADDRESS:-[::]:${PORT:-9000}}"
if [ -z "${GRAYLOG_HTTP_EXTERNAL_URI:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export GRAYLOG_HTTP_EXTERNAL_URI="https://${RAILWAY_PUBLIC_DOMAIN}/"
fi
export GRAYLOG_SERVER_JAVA_OPTS="${GRAYLOG_SERVER_JAVA_OPTS:--Xms1g -Xmx1g -XX:+UseG1GC -server -XX:-OmitStackTraceInFastThrow}"
# Single server: skip the version check and telemetry calls home unless the deployer opts in.
export GRAYLOG_VERSIONCHECKS="${GRAYLOG_VERSIONCHECKS:-false}"
export GRAYLOG_TELEMETRY_ENABLED="${GRAYLOG_TELEMETRY_ENABLED:-false}"

DATA=/usr/share/graylog/data
mkdir -p "$DATA"
chown -R graylog:graylog "$DATA"

exec setpriv --reuid=graylog --regid=graylog --init-groups /usr/bin/tini -- /docker-entrypoint.sh server
