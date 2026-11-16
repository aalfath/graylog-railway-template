# Graylog server, official image pinned by version and digest.
FROM graylog/graylog:7.2.2@sha256:d4cf618fa0b1d44f639e5fe37c77a1b332f74ae69bd6d77f2b9b94bb2f2e067d

# Start as root so the wrapper can fix the ownership of the Railway volume,
# then it drops to the image's graylog user before starting the server.
USER root
COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
