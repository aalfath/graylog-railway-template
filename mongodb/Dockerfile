# MongoDB for Graylog's configuration data, official image pinned by version and digest.
# Graylog 7.2 supports MongoDB 7.x to 8.3; 7.0 avoids the MongoDB 8 crash on Linux 6.19+ hosts.
FROM mongo:7.0.48@sha256:9896df581dfd0718b7abe112f4c37598d0986c54060e4ec1384997e6503c8c71

# Railway's private network is IPv6, so listen on :: as well as 0.0.0.0.
CMD ["mongod", "--ipv6", "--bind_ip_all"]
