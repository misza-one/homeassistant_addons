ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN \
    apk add --no-cache \
        bash=5.2.15-r5 \
        curl=8.5.0-r0 \
        jq=1.7.1-r0 \
        iptables=1.8.10-r3 \
        ip6tables=1.8.10-r3 \
        iproute2=6.6.0-r0 \
        procps=4.0.4-r0 \
        python3=3.11.8-r0 \
        py3-pip=23.3.1-r0 \
        nginx=1.24.0-r15

# Install Zerotier
RUN \
    curl -s https://install.zerotier.com | sh \
    && mkdir -p /var/lib/zerotier-one

# Install web interface dependencies
RUN pip3 install --no-cache-dir flask==2.3.3 requests==2.31.0

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