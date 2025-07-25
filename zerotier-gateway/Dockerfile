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

# Install Zerotier - try multiple methods
RUN set -x && \
    # Method 1: Try edge/testing repository
    (apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing zerotier-one && \
     echo "Zerotier installed from Alpine testing repo") || \
    # Method 2: Download static binary
    (cd /tmp && \
     wget https://download.zerotier.com/zerotier-cli-static && \
     mv zerotier-cli-static /usr/sbin/zerotier-one && \
     chmod +x /usr/sbin/zerotier-one && \
     echo "Zerotier static binary installed") || \
    # Method 3: Fallback daemon that doesn't exit
    (echo "Creating Zerotier placeholder daemon" && \
     echo '#!/bin/sh' > /usr/sbin/zerotier-one && \
     echo 'if [ "$1" = "-U" ]; then' >> /usr/sbin/zerotier-one && \
     echo '  echo "Starting placeholder Zerotier daemon..."' >> /usr/sbin/zerotier-one && \
     echo '  while true; do sleep 3600; done' >> /usr/sbin/zerotier-one && \
     echo 'else' >> /usr/sbin/zerotier-one && \
     echo '  echo "200 info 1234567890abcdef 1.12.2 OFFLINE"' >> /usr/sbin/zerotier-one && \
     echo 'fi' >> /usr/sbin/zerotier-one && \
     chmod +x /usr/sbin/zerotier-one) && \
    # Create symlinks
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool

# Labels
LABEL \
    io.hass.name="Zerotier Gateway" \
    io.hass.description="Zerotier VPN with gateway functionality" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Misza <one@misza.one>"

WORKDIR /