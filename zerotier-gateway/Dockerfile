ARG BUILD_FROM
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
        openssl

# Install ZeroTier based on architecture
ARG BUILD_ARCH
RUN \
    mkdir -p /var/lib/zerotier-one && \
    cd /tmp && \
    ARCH="${BUILD_ARCH}" && \
    echo "Installing ZeroTier for architecture: $ARCH" && \
    # For amd64 and arm64, build from source
    if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "aarch64" ]; then \
        echo "Building ZeroTier from source..." && \
        apk add --no-cache --virtual .build-deps \
            git \
            make \
            gcc \
            g++ \
            linux-headers \
            openssl-dev \
            cargo \
            rust && \
        git clone --depth 1 --branch 1.14.2 https://github.com/zerotier/ZeroTierOne.git && \
        cd ZeroTierOne && \
        make -j$(nproc) one && \
        cp zerotier-one /usr/sbin/ && \
        cd / && \
        rm -rf /tmp/ZeroTierOne && \
        apk del .build-deps && \
        echo "ZeroTier built from source"; \
    else \
        echo "Using placeholder for unsupported architecture: $ARCH" && \
        printf '#!/bin/sh\n' > /usr/sbin/zerotier-one && \
        printf '# Zerotier placeholder for %s\n' "$ARCH" >> /usr/sbin/zerotier-one && \
        printf 'echo "ZeroTier placeholder - architecture %s not yet supported"\n' "$ARCH" >> /usr/sbin/zerotier-one && \
        printf 'echo "Only amd64 and aarch64 are currently supported with real ZeroTier"\n' >> /usr/sbin/zerotier-one && \
        printf 'exit 1\n' >> /usr/sbin/zerotier-one; \
    fi && \
    chmod +x /usr/sbin/zerotier-one && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool

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