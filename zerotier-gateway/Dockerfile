ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
        libgcc \
        gpg \
        gpg-agent

# Install ZeroTier
RUN \
    curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
    if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | bash; fi && \
    mkdir -p /var/lib/zerotier-one

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