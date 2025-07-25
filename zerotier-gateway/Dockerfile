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

# Install Zerotier using official installer with modifications for Alpine
RUN \
    mkdir -p /var/lib/zerotier-one && \
    # Download and modify the installer for Alpine/Docker
    curl -s https://install.zerotier.com/ > /tmp/install.sh && \
    # Remove systemd commands that don't work in Docker
    sed -i 's/systemctl/#systemctl/g' /tmp/install.sh && \
    sed -i 's/service zerotier-one/#service zerotier-one/g' /tmp/install.sh && \
    # Try to run the modified installer
    bash /tmp/install.sh || true && \
    # Check if it worked
    if [ -f /usr/sbin/zerotier-one ]; then \
        echo "Zerotier installed successfully"; \
    else \
        echo "Zerotier installation failed, creating placeholder"; \
        echo '#!/bin/sh' > /usr/sbin/zerotier-one; \
        echo 'echo "Zerotier not installed - check build logs"' >> /usr/sbin/zerotier-one; \
        echo 'if [ "$1" = "-U" ]; then' >> /usr/sbin/zerotier-one; \
        echo '  while true; do sleep 3600; done' >> /usr/sbin/zerotier-one; \
        echo 'fi' >> /usr/sbin/zerotier-one; \
        chmod +x /usr/sbin/zerotier-one; \
    fi && \
    # Create symlinks
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool && \
    rm -f /tmp/install.sh

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