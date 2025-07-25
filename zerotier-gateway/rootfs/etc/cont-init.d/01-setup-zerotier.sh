#!/usr/bin/with-contenv bashio

bashio::log.info "Setting up Zerotier service..."

# Load configuration
CONFIG_FILE="/tmp/zerotier-gateway/config.json"
NETWORK_ID=$(jq -r '.network_id' $CONFIG_FILE)
AUTH_TOKEN=$(jq -r '.auth_token' $CONFIG_FILE)

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