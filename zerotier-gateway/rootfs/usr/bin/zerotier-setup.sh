#!/usr/bin/with-contenv bashio

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
timeout=300  # Increased to 5 minutes
while [ $timeout -gt 0 ]; do
    if zerotier-cli listnetworks | grep -q "${NETWORK_ID}"; then
        STATUS=$(zerotier-cli listnetworks | grep "${NETWORK_ID}" | awk '{print $6}')
        if [[ "$STATUS" == "OK" ]]; then
            bashio::log.info "Successfully joined network!"
            break
        elif [[ "$STATUS" == "ACCESS_DENIED" ]]; then
            bashio::log.warning "Access denied! Please authorize this device in Zerotier Central"
            break
        fi
    fi
    sleep 5
    timeout=$((timeout-5))
    if [ $((timeout % 30)) -eq 0 ]; then
        bashio::log.info "Still waiting for network authorization... ($timeout seconds remaining)"
    fi
done

if [ $timeout -le 0 ]; then
    bashio::log.warning "Network join timed out. Check Zerotier Central to authorize this device."
fi

# Get network info - handle different output formats
NETWORK_INFO=$(zerotier-cli listnetworks | grep "${NETWORK_ID}")
if [[ -n "$NETWORK_INFO" ]]; then
    # Real ZeroTier output format: 200 listnetworks <nwid> <name> <mac> <status> <type> <dev> <ZT assigned ips>
    # The IP might be in different positions depending on the status
    # Try to find an IP address pattern in the line
    ZT_IP=$(echo "$NETWORK_INFO" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' | head -1 | cut -d'/' -f1)
    
    # Device name is typically the 8th field but could vary
    ZT_DEVICE=$(echo "$NETWORK_INFO" | awk '{
        for(i=1;i<=NF;i++) {
            if($i ~ /^zt[a-z0-9]+$/) {
                print $i
                exit
            }
        }
    }')
    
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