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
        procps

# Create directories
RUN mkdir -p /var/lib/zerotier-one

# Copy root filesystem
COPY rootfs /

# Set permissions
RUN chmod a+x /usr/bin/*.sh || true \
    && chmod a+x /etc/services.d/*/run || true \
    && chmod a+x /etc/services.d/*/finish || true \
    && chmod a+x /etc/cont-init.d/*.sh || true

# Temporary: Create a fake zerotier-one binary to test the addon
RUN echo '#!/bin/sh' > /usr/sbin/zerotier-one && \
    echo 'echo "Zerotier placeholder - real installation coming soon"' >> /usr/sbin/zerotier-one && \
    echo 'while true; do sleep 30; done' >> /usr/sbin/zerotier-one && \
    chmod +x /usr/sbin/zerotier-one && \
    ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool

# Labels
LABEL \
    io.hass.name="Zerotier Gateway" \
    io.hass.description="Zerotier VPN with gateway functionality" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Misza <one@misza.one>"

WORKDIR /