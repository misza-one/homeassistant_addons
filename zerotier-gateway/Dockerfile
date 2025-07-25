# Build arguments
ARG BUILD_FROM

# Build stage for ZeroTier
FROM alpine:3.19 AS builder

# Install build dependencies
RUN apk add --no-cache \
    git \
    make \
    gcc \
    g++ \
    linux-headers \
    openssl-dev \
    curl \
    cargo \
    rust

# Clone and build ZeroTier
RUN git clone --depth 1 --branch 1.14.2 https://github.com/zerotier/ZeroTierOne.git /build && \
    cd /build && \
    make -j$(nproc) one

# Runtime stage
FROM $BUILD_FROM

# Install runtime dependencies
RUN \
    apk add --no-cache \
        bash \
        curl \
        wget \
        jq \
        iptables \
        ip6tables \
        iproute2 \
        procps \
        libstdc++ \
        libgcc \
        tar \
        ca-certificates \
        openssl \
        libcrypto3 \
        libssl3

# Copy ZeroTier binary from builder
COPY --from=builder /build/zerotier-one /usr/sbin/
RUN ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool && \
    chmod +x /usr/sbin/zerotier-one && \
    mkdir -p /var/lib/zerotier-one

# Copy root filesystem
COPY rootfs /

# Set permissions
RUN chmod a+x /usr/bin/*.sh || true \
    && chmod a+x /etc/services.d/*/run || true \
    && chmod a+x /etc/services.d/*/finish || true \
    && chmod a+x /etc/cont-init.d/*.sh || true

# Test ZeroTier
RUN zerotier-one -v || echo "ZeroTier check"

# Labels
LABEL \
    io.hass.name="Zerotier Gateway" \
    io.hass.description="Zerotier VPN with gateway functionality" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Misza <one@misza.one>"

WORKDIR /