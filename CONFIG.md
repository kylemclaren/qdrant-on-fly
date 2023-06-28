# A non-exhaustive list of QDrant configration envrionment variables

The environment variable names should be prefixed with `QDRANT_` and use double underscores (`__`) to represent nested keys. 

Here's a list of the possible environment variables:

1. `QDRANT_DEBUG`: A boolean to enable or disable debug mode.
2. `QDRANT_LOG_LEVEL`: A string to set the log level. For example: "INFO", "DEBUG", etc.
3. `QDRANT_TELEMETRY_DISABLED`: A boolean to enable or disable telemetry.
4. `QDRANT_SERVICE__HOST`: A string to set the service host.
5. `QDRANT_SERVICE__HTTP_PORT`: An unsigned 16-bit integer to set the HTTP port.
6. `QDRANT_SERVICE__GRPC_PORT`: An optional unsigned 16-bit integer to set the gRPC port.
7. `QDRANT_SERVICE__MAX_REQUEST_SIZE_MB`: An unsigned integer to set the maximum request size in MB.
8. `QDRANT_SERVICE__MAX_WORKERS`: An optional unsigned integer to set the maximum number of workers.
9. `QDRANT_SERVICE__ENABLE_CORS`: A boolean to enable or disable CORS.
10. `QDRANT_SERVICE__ENABLE_TLS`: A boolean to enable or disable TLS.
11. `QDRANT_SERVICE__VERIFY_HTTPS_CLIENT_CERTIFICATE`: A boolean to enable or disable HTTPS client certificate verification.
12. `QDRANT_CLUSTER__ENABLED`: A boolean to enable or disable the cluster.
13. `QDRANT_CLUSTER__GRPC_TIMEOUT_MS`: An unsigned 64-bit integer to set the gRPC timeout in milliseconds.
14. `QDRANT_CLUSTER__CONNECTION_TIMEOUT_MS`: An unsigned 64-bit integer to set the connection timeout in milliseconds.
15. `QDRANT_CLUSTER__P2P__PORT`: An optional unsigned 16-bit integer to set the P2P port.
16. `QDRANT_CLUSTER__P2P__CONNECTION_POOL_SIZE`: An unsigned integer to set the P2P connection pool size.
17. `QDRANT_CLUSTER__P2P__ENABLE_TLS`: A boolean to enable or disable TLS for P2P.
18. `QDRANT_CLUSTER__CONSENSUS__MAX_MESSAGE_QUEUE_SIZE`: An unsigned integer to set the maximum message queue size.
19. `QDRANT_CLUSTER__CONSENSUS__TICK_PERIOD_MS`: An unsigned 64-bit integer to set the tick period in milliseconds.
20. `QDRANT_CLUSTER__CONSENSUS__BOOTSTRAP_TIMEOUT_SEC`: An unsigned 64-bit integer to set the bootstrap timeout in seconds.
21. `QDRANT_TLS__CERT`: A string for the TLS certificate.
22. `QDRANT_TLS__KEY`: A string for the TLS key.
23. `QDRANT_TLS__CA_CERT`: A string for the TLS CA certificate.
