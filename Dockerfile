# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds

FROM alpine:latest as builder
WORKDIR /app
COPY . ./

FROM alpine:latest as tailscale
WORKDIR /app
ENV TSFILE=tailscale_1.42.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

ENV QDRANT_VERSION=v1.2.0
# FROM qdrant/qdrant:${QDRANT_VERSION}
FROM qdrant/qdrant:v1.2.2

# COPY ./config/config.yml /qdrant/config/production.yaml

RUN apt-get update && apt-get install ca-certificates iptables -y
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy
RUN update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

COPY --from=builder /app/start-seed.sh /app/start-seed.sh
COPY --from=builder /app/start-peer.sh /app/start-peer.sh
RUN chmod +x /app/start-seed.sh && chmod +x /app/start-peer.sh

# Copy binary to production image
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]