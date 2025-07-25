#!/bin/bash

CONFIG_FILE="/tmp/zerotier-gateway/config.json"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    NETWORK_ID=$(jq -r '.network_id' $CONFIG_FILE)
    AUTO_AUTHORIZE=$(jq -r '.auto_authorize' $CONFIG_FILE)
else
    # Fallback to bashio config
    NETWORK_ID=$(bashio::config 'network_id')
    AUTO_AUTHORIZE=$(bashio::config 'auto_authorize')
fi

bashio::log.info "Joining Zerotier network: ${NETWORK_ID}"

# Join the network
zerotier-cli join "${NETWORK_ID}"

# Wait for network to be available
timeout=120
while [ $timeout -gt 0 ]; do
    if zerotier-cli listnetworks | grep -q "${NETWORK_ID}"; then
        STATUS=$(zerotier-cli listnetworks | grep "${NETWORK_ID}" | awk '{print $6}')
        if [[ "$STATUS" == "OK" ]]; then
            bashio::log.info "Successfully joined network!"
            break
        fi
    fi
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    bashio::log.warning "Network join timed out. Check Zerotier Central to authorize this device."
fi

# Get network info
NETWORK_INFO=$(zerotier-cli listnetworks | grep "${NETWORK_ID}")
if [[ -n "$NETWORK_INFO" ]]; then
    ZT_IP=$(echo "$NETWORK_INFO" | awk '{print $9}' | cut -d'/' -f1)
    ZT_DEVICE=$(echo "$NETWORK_INFO" | awk '{print $8}')
    
    bashio::log.info "Zerotier IP: ${ZT_IP}"
    bashio::log.info "Zerotier Device: ${ZT_DEVICE}"
    
    # Save network info
    cat > /tmp/zerotier-gateway/network.json << EOF
{
    "ip": "${ZT_IP}",
    "device": "${ZT_DEVICE}",
    "network_id": "${NETWORK_ID}"
}
EOF
fi