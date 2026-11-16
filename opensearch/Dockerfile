# OpenSearch search backend for Graylog, official image pinned by version and digest.
# Graylog 7.2 supports OpenSearch 2.0 to 3.7.
FROM opensearchproject/opensearch:2.19.7@sha256:d89333b6bd4a13b9a95aef7f373c0a6e73440f59bc0d8d1460f9b347289ed0ef

USER root
COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
