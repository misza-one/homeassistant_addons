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
        libgcc \
        ca-certificates

# Download and install Zerotier binary directly
RUN \
    mkdir -p /var/lib/zerotier-one && \
    cd /tmp && \
    # Download the installer script and extract the download URLs
    curl -s https://install.zerotier.com/ > install.sh && \
    # Try to run the installer
    sh install.sh || true && \
    # Check if zerotier-one exists, if not download manually
    if [ ! -f /usr/sbin/zerotier-one ]; then \
        echo "Installer failed, downloading manually..." && \
        ARCH=$(uname -m) && \
        if [ "$ARCH" = "x86_64" ]; then \
            curl -L https://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/zerotier-one_1.12.2_amd64.deb -o zt.deb && \
            ar x zt.deb && tar -xf data.tar.xz && \
            cp -a usr/sbin/zerotier-one /usr/sbin/ || true; \
        elif [ "$ARCH" = "aarch64" ]; then \
            curl -L https://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/zerotier-one_1.12.2_arm64.deb -o zt.deb && \
            ar x zt.deb && tar -xf data.tar.xz && \
            cp -a usr/sbin/zerotier-one /usr/sbin/ || true; \
        fi; \
    fi && \
    # Final check and create placeholder if all else fails
    if [ ! -f /usr/sbin/zerotier-one ]; then \
        echo "All installation methods failed, creating placeholder" && \
        printf '#!/bin/sh\necho "Zerotier not installed"\nexit 1\n' > /usr/sbin/zerotier-one; \
    fi && \
    chmod +x /usr/sbin/zerotier-one && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -sf /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool && \
    # Clean up
    rm -rf /tmp/*

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