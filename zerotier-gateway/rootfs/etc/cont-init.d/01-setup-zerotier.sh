#!/usr/bin/with-contenv bashio

bashio::log.info "Setting up Zerotier service..."

# Wait for config file from previous script
CONFIG_FILE="/tmp/zerotier-gateway/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    bashio::log.error "Config file not found. Waiting for initialization..."
    sleep 2
fi

# Load configuration directly from bashio if file doesn't exist
if [ -f "$CONFIG_FILE" ]; then
    NETWORK_ID=$(jq -r '.network_id' $CONFIG_FILE)
    AUTH_TOKEN=$(jq -r '.auth_token' $CONFIG_FILE)
else
    NETWORK_ID=$(bashio::config 'network_id')
    AUTH_TOKEN=$(bashio::config 'auth_token')
fi

# Set up auth token if provided
if [[ "${AUTH_TOKEN}" != "null" && "${AUTH_TOKEN}" != "" ]]; then
    bashio::log.info "Configuring auth token..."
    echo "${AUTH_TOKEN}" > /var/lib/zerotier-one/authtoken.secret
    chmod 600 /var/lib/zerotier-one/authtoken.secret
fi

# Ensure zerotier directories have correct permissions
chown -R root:root /var/lib/zerotier-one
chmod 755 /var/lib/zerotier-one

bashio::log.info "Zerotier setup completed"
bashio::log.info "Network ID: ${NETWORK_ID}"