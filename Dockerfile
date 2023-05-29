# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds

ARG QDRANT_VERSION=v1.2.2

FROM alpine:latest as builder
WORKDIR /app
COPY . ./
ENV TSFILE=tailscale_1.42.0_amd64.tgz
RUN apk update && apk add wget && \
  wget --progress=dot https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM qdrant/qdrant:${QDRANT_VERSION}

RUN apt-get update && apt-get install ca-certificates iptables jq --no-install-recommends -y
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy
RUN update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Copy binary to production image
COPY --from=builder /app/tailscaled /app/tailscaled
COPY --from=builder /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY --from=builder /app/start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]