ARG BUILD_FROM
FROM $BUILD_FROM

# Install all packages including build dependencies
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
        build-base \
        linux-headers \
        git \
        cmake

# Build and install Zerotier
RUN \
    cd /tmp && \
    git clone --depth 1 --branch 1.12.2 https://github.com/zerotier/ZeroTierOne.git && \
    cd ZeroTierOne && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/ZeroTierOne && \
    # Remove build dependencies to reduce image size
    apk del build-base linux-headers git cmake && \
    # Create directory
    mkdir -p /var/lib/zerotier-one

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