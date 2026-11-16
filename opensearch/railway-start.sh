#!/bin/bash
# Railway wrapper for OpenSearch as Graylog's private search backend.
# It is reachable only on the project's private network, so the security plugin is off
# (the same setup as Graylog's own Docker Compose example).
set -euo pipefail

DATA=/usr/share/opensearch/data
mkdir -p "$DATA"
chown -R 1000:1000 "$DATA"

export OPENSEARCH_JAVA_OPTS="${OPENSEARCH_JAVA_OPTS:--Xms1g -Xmx1g}"
export DISABLE_INSTALL_DEMO_CONFIG=true
export DISABLE_SECURITY_PLUGIN=true

EXTRA=""
# Railway hosts differ in vm.max_map_count, and a container can't raise it.
# Below OpenSearch's minimum, fall back to niofs instead of mmap.
MMC="$(cat /proc/sys/vm/max_map_count 2>/dev/null || echo 0)"
if [ "$MMC" -lt 262144 ]; then
  echo "vm.max_map_count=$MMC is below 262144: starting with node.store.allow_mmap=false"
  EXTRA="-Enode.store.allow_mmap=false"
fi

exec chroot --userspec=1000:1000 / env HOME=/usr/share/opensearch bash -c "cd /usr/share/opensearch && exec ./opensearch-docker-entrypoint.sh opensearch \
  -Ecluster.name=graylog \
  -Ediscovery.type=single-node \
  -Ehttp.host=:: \
  -Ehttp.port=${PORT:-9200} \
  -Etransport.host=127.0.0.1 \
  -Eaction.auto_create_index=false \
  -Ebootstrap.memory_lock=false \
  $EXTRA"
