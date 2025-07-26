#!/usr/bin/with-contenv bashio

# This script monitors gateway readiness and provides feedback

NETWORK_FILE="/tmp/zerotier-gateway/network.json"

if [ ! -f "$NETWORK_FILE" ]; then
    exit 0
fi

ZT_DEVICE=$(jq -r '.device' $NETWORK_FILE 2>/dev/null)
ZT_IP=$(jq -r '.ip' $NETWORK_FILE 2>/dev/null)

if [[ -z "$ZT_DEVICE" || -z "$ZT_IP" ]]; then
    exit 0
fi

# Check if we can reach the ZeroTier network
if ping -c 1 -W 1 -I ${ZT_DEVICE} 192.168.195.1 >/dev/null 2>&1; then
    if [ ! -f /tmp/gateway-ready ]; then
        touch /tmp/gateway-ready
        bashio::log.info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        bashio::log.info "✅ GATEWAY IS FULLY OPERATIONAL!"
        bashio::log.info "You can now access your local network from ZeroTier devices"
        bashio::log.info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
fi