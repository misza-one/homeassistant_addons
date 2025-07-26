#!/usr/bin/with-contenv bashio

bashio::log.info "Initializing Zerotier Gateway Add-on..."

# Create necessary directories
mkdir -p /tmp/zerotier-gateway
mkdir -p /data/zerotier-one

# Use persistent storage for ZeroTier identity
if [ ! -L /var/lib/zerotier-one ]; then
    rm -rf /var/lib/zerotier-one
    ln -s /data/zerotier-one /var/lib/zerotier-one
    bashio::log.info "Linked ZeroTier data directory to persistent storage"
fi

# Show existing identity if present
if [ -f /data/zerotier-one/identity.secret ]; then
    bashio::log.info "Using existing ZeroTier identity"
else
    bashio::log.info "New ZeroTier identity will be created"
fi

# Set up TUN device
if [ ! -c /dev/net/tun ]; then
    bashio::log.info "Creating TUN device..."
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# Enable IP forwarding
bashio::log.info "Checking IP forwarding..."
if [ -w /proc/sys/net/ipv4/ip_forward ]; then
    echo 1 > /proc/sys/net/ipv4/ip_forward
    bashio::log.info "IP forwarding enabled"
else
    bashio::log.info "IP forwarding will be handled by host settings"
fi

# Load configuration
NETWORK_ID=$(bashio::config 'network_id')
LOCAL_SUBNET=$(bashio::config 'local_subnet')
AUTH_TOKEN=$(bashio::config 'auth_token')
ENABLE_GATEWAY=$(bashio::config 'enable_gateway')
AUTO_AUTHORIZE=$(bashio::config 'auto_authorize')

# Validate required config
if bashio::var.is_empty "${NETWORK_ID}"; then
    bashio::exit.nok "Network ID is required!"
fi

if [[ ${#NETWORK_ID} != 16 ]]; then
    bashio::exit.nok "Network ID must be exactly 16 characters!"
fi

# Save config for other scripts
cat > /tmp/zerotier-gateway/config.json << EOF
{
    "network_id": "${NETWORK_ID}",
    "local_subnet": "${LOCAL_SUBNET}",
    "auth_token": "${AUTH_TOKEN}",
    "enable_gateway": ${ENABLE_GATEWAY},
    "auto_authorize": ${AUTO_AUTHORIZE}
}
EOF

bashio::log.info "System initialization completed"