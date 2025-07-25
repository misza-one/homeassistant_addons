ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install packages and build dependencies
RUN \
    apk add --no-cache \
        bash \
        curl \
        jq \
        iptables \
        ip6tables \
        iproute2 \
        procps \
        make \
        g++ \
        linux-headers

# Build and install Zerotier
RUN \
    cd /tmp && \
    curl -Lo zerotier.tar.gz https://github.com/zerotier/ZeroTierOne/archive/refs/tags/1.12.2.tar.gz && \
    tar -xzf zerotier.tar.gz && \
    cd ZeroTierOne-1.12.2 && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/zerotier* /tmp/ZeroTierOne* && \
    mkdir -p /var/lib/zerotier-one

# Install web interface dependencies (removed for now - not needed for basic functionality)
# RUN pip3 install --no-cache-dir flask requests

# Copy root filesystem
COPY rootfs /

# Set permissions
RUN chmod a+x /usr/bin/*.sh \
    && chmod a+x /etc/services.d/*/run \
    && chmod a+x /etc/services.d/*/finish \
    && chmod a+x /etc/cont-init.d/*.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD zerotier-cli info || exit 1

# Labels
LABEL \
    io.hass.name="Zerotier Gateway" \
    io.hass.description="Zerotier VPN with gateway functionality" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Misza <one@misza.one>" \
    org.opencontainers.image.title="Zerotier Gateway" \
    org.opencontainers.image.description="Zerotier VPN with gateway functionality" \
    org.opencontainers.image.source="https://github.com/misza-one/homeassistant_addons" \
    org.opencontainers.image.licenses="MIT"

WORKDIR /