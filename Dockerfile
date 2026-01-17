# Dockerfile for rmotly-server
# Build context should be the repository root

# Build stage - using Flutter image since serverpod generate requires Flutter
FROM ghcr.io/cirruslabs/flutter:3.29.0 AS build
WORKDIR /app

# Copy the entire project for serverpod generate
COPY rmotly_server/ ./rmotly_server/
COPY rmotly_client/ ./rmotly_client/

WORKDIR /app/rmotly_server

# Get dependencies
RUN dart pub get

# Generate Serverpod code
RUN dart pub global activate serverpod_cli
ENV PATH="$PATH:/root/.pub-cache/bin"
RUN serverpod generate

# Compile the server executable
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM debian:bookworm-slim

# Install required runtime libraries
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy compiled server executable
COPY --from=build /app/rmotly_server/bin/server /app/server

# Copy configuration files and resources
COPY --from=build /app/rmotly_server/config/ /app/config/
COPY --from=build /app/rmotly_server/web/ /app/web/
COPY --from=build /app/rmotly_server/migrations/ /app/migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /app/rmotly_server/lib/src/generated/protocol.yaml /app/lib/src/generated/protocol.yaml

# Expose ports
# 8080 - API server
# 8081 - Insights server
# 8082 - Web server
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Define the entrypoint command
ENTRYPOINT ["/app/server"]
CMD ["--mode", "production", "--server-id", "default", "--logging", "normal", "--role", "monolith"]
