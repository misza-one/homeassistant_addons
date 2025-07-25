# Build stage for Zerotier
FROM alpine:3.19 AS builder

RUN apk add --no-cache \
    build-base \
    linux-headers \
    git \
    cmake

RUN cd /tmp && \
    git clone --depth 1 --branch 1.12.2 https://github.com/zerotier/ZeroTierOne.git && \
    cd ZeroTierOne && \
    make -j$(nproc) && \
    strip zerotier-one

# Final stage
ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN \
    apk add --no-cache \
        bash \
        curl \
        jq \
        iptables \
        ip6tables \
        iproute2 \
        procps \
        libstdc++ \
        libgcc

# Copy Zerotier binary from builder
COPY --from=builder /tmp/ZeroTierOne/zerotier-one /usr/sbin/zerotier-one

# Set up Zerotier
RUN \
    chmod +x /usr/sbin/zerotier-one && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool && \
    mkdir -p /var/lib/zerotier-one

# Copy root filesystem
COPY rootfs /

# Set permissions
RUN chmod a+x /usr/bin/*.sh || true \
    && chmod a+x /etc/services.d/*/run || true \
    && chmod a+x /etc/services.d/*/finish || true \
    && chmod a+x /etc/cont-init.d/*.sh || true

# Labels
LABEL \
    io.hass.name="Zerotier Gateway" \
    io.hass.description="Zerotier VPN with gateway functionality" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Misza <one@misza.one>"

WORKDIR /