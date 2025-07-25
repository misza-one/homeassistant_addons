ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
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
        tar \
        libstdc++ \
        libgcc

# Download and install Zerotier based on architecture
RUN \
    mkdir -p /var/lib/zerotier-one && \
    cd /tmp && \
    # Use architecture from build arg
    ARCH="${BUILD_ARCH}" && \
    echo "Installing Zerotier for architecture: $ARCH" && \
    # Download the appropriate binary
    if [ "$ARCH" = "amd64" ]; then \
        wget -O zt.tar.gz "https://download.zerotier.com/RELEASES/1.12.2/dist/linux/zerotier-cli-linux-x64-1_12_2.tar.gz" || \
        wget -O zt.tar.gz "https://github.com/zerotier/ZeroTierOne/releases/download/1.12.2/zerotier-one-linux-amd64-1.12.2.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "armv7" ] || [ "$ARCH" = "armhf" ]; then \
        wget -O zt.tar.gz "https://download.zerotier.com/RELEASES/1.12.2/dist/linux/zerotier-cli-linux-arm64-1_12_2.tar.gz" || \
        wget -O zt.tar.gz "https://github.com/zerotier/ZeroTierOne/releases/download/1.12.2/zerotier-one-linux-arm64-1.12.2.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    # Extract and install
    if [ -f zt.tar.gz ]; then \
        tar -xzf zt.tar.gz || tar -xf zt.tar.gz || (echo "Failed to extract" && exit 1); \
        # Find and copy the binary
        find . -name "zerotier-one" -type f -exec cp {} /usr/sbin/zerotier-one \; || \
        find . -name "zerotier-cli" -type f -exec cp {} /usr/sbin/zerotier-one \; || \
        cp zerotier-one /usr/sbin/ 2>/dev/null || \
        cp zerotier-cli /usr/sbin/zerotier-one 2>/dev/null || \
        (echo "Could not find zerotier binary" && exit 1); \
    else \
        echo "Download failed" && exit 1; \
    fi && \
    # Make executable and create symlinks
    chmod +x /usr/sbin/zerotier-one && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool && \
    # Clean up
    cd / && rm -rf /tmp/* && \
    # Test
    echo "Testing Zerotier installation..." && \
    /usr/sbin/zerotier-one -v || echo "Binary installed"

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