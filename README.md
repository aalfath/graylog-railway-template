# Graylog on Railway

A Railway template for [Graylog](https://graylog.org/) Open, the open-source log management platform: collect, index, search and alert on logs from your servers and apps.

It deploys three services, each built from this repo's Dockerfiles, which pin the official images by version and digest:

| Service | Folder | Image | Volume |
|---|---|---|---|
| `Graylog` (public) | `graylog/` | `graylog/graylog:7.2.2` | `/usr/share/graylog/data` (journal, node ID) |
| `OpenSearch` (private) | `opensearch/` | `opensearchproject/opensearch:2.19.7` | `/usr/share/opensearch/data` (your logs) |
| `MongoDB` (private) | `mongodb/` | `mongo:7.0.48` | `/data/db` (users, inputs, streams, dashboards) |

Versions follow Graylog's [compatibility matrix](https://go2docs.graylog.org/current/downloading_and_installing_graylog/compatibility_matrix.htm): Graylog 7.2 supports MongoDB 7.x to 8.3 and OpenSearch 2.0 to 3.7.

## Variables

| Service | Variable | Default | What it is |
|---|---|---|---|
| Graylog | `GRAYLOG_ROOT_PASSWORD` | generated | Password of the `admin` user. Change it and redeploy to change the admin password |
| Graylog | `GRAYLOG_PASSWORD_SECRET` | generated | Secret that Graylog uses to encrypt and salt stored secrets. Never change it after the first deploy |
| Graylog | `GRAYLOG_MONGODB_URI` | reference | MongoDB connection over the private network |
| Graylog | `GRAYLOG_ELASTICSEARCH_HOSTS` | reference | OpenSearch address over the private network |
| Graylog | `PORT` | `9000` | Web interface and REST API port |
| OpenSearch | `PORT` | `9200` | OpenSearch HTTP port (private network only) |
| MongoDB | `MONGO_INITDB_ROOT_USERNAME` | `graylog` | MongoDB root user |
| MongoDB | `MONGO_INITDB_ROOT_PASSWORD` | generated | MongoDB root password |
| all three | `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `30` | Time each service gets to shut down cleanly on a redeploy (Graylog flushes its journal, OpenSearch and MongoDB close their files) |

The deploy page asks for nothing. After the deploy, open the Graylog domain and sign in as `admin` with the `GRAYLOG_ROOT_PASSWORD` value from the Graylog service's Variables tab.

Optional settings: any Graylog setting can be set as a `GRAYLOG_<SETTING>` variable on the Graylog service (for example `GRAYLOG_TRANSPORT_EMAIL_ENABLED=true` and the other `GRAYLOG_TRANSPORT_EMAIL_*` settings for email alerts). Heap sizes default to 1 GB each and can be changed with `GRAYLOG_SERVER_JAVA_OPTS` on Graylog and `OPENSEARCH_JAVA_OPTS` on OpenSearch.

## Sending logs to Graylog

Inputs are created in the web interface (System → Inputs). Railway can route HTTP and TCP to a service, but not UDP, so:

- **GELF HTTP**: launch a "GELF HTTP" input on port `12201` with bind address `::`, then add a second Railway domain on the Graylog service with target port `12201`. Send JSON to `https://YOUR-INPUT-DOMAIN/gelf`.
- **Syslog TCP, GELF TCP, Beats**: launch the input on a port of your choice with bind address `::`, then add a Railway TCP proxy for that port.
- **Apps in the same Railway project**: send to `graylog.railway.internal:<input port>` over the private network; no domain needed.

## How the wrapper works

- `graylog/railway-start.sh` turns `GRAYLOG_ROOT_PASSWORD` into the SHA-256 that Graylog expects, sets `http_external_uri` from Railway's public domain, binds the web interface on `[::]:$PORT`, turns off version checks and telemetry, fixes the volume's ownership and starts the image's own entrypoint as the `graylog` user.
- `opensearch/railway-start.sh` runs a single node with the security plugin off (it is reachable only on the project's private network, as in Graylog's own Docker Compose example), listens on IPv6 for Railway's private network and falls back to `node.store.allow_mmap=false` on hosts with a low `vm.max_map_count`.
- `mongodb/Dockerfile` starts `mongod` with IPv6 enabled, so Graylog can reach it on the private network.

## Updates

Each service builds from this repo's `main` branch. When a new Graylog, OpenSearch or MongoDB version is pinned here, Railway shows deployers an "update available" notice, and they choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry.

Only upgrade MongoDB and OpenSearch to versions Graylog supports, and take a backup of the volumes before a major upgrade.

## License

This wrapper is MIT licensed. Graylog Open is licensed under the [Server Side Public License](https://github.com/Graylog2/graylog2-server/blob/master/LICENSE); OpenSearch under Apache 2.0; MongoDB Community under the SSPL.
