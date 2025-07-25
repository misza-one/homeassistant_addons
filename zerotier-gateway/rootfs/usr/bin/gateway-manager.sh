#!/bin/bash

CONFIG_FILE="/tmp/zerotier-gateway/config.json"
NETWORK_FILE="/tmp/zerotier-gateway/network.json"

# Load configuration
ENABLE_GATEWAY=$(jq -r '.enable_gateway' $CONFIG_FILE)
LOCAL_SUBNET=$(jq -r '.local_subnet' $CONFIG_FILE)

# Wait for zerotier to be ready and join network
/usr/bin/zerotier-setup.sh

# Setup gateway if enabled
if [[ "$ENABLE_GATEWAY" == "true" ]]; then
    bashio::log.info "Setting up gateway functionality..."
    
    # Wait for network file to be created
    timeout=30
    while [ ! -f "$NETWORK_FILE" ] && [ $timeout -gt 0 ]; do
        sleep 1
        timeout=$((timeout-1))
    done
    
    if [ ! -f "$NETWORK_FILE" ]; then
        bashio::log.error "Network information not available, cannot setup gateway"
        exit 1
    fi
    
    # Load network info
    ZT_DEVICE=$(jq -r '.device' $NETWORK_FILE)
    ZT_IP=$(jq -r '.ip' $NETWORK_FILE)
    
    if [[ "$ZT_DEVICE" != "null" && "$ZT_IP" != "null" ]]; then
        # Get default interface
        DEFAULT_IF=$(ip route | grep default | awk '{print $5}' | head -n1)
        
        bashio::log.info "Setting up iptables rules..."
        bashio::log.info "Zerotier device: ${ZT_DEVICE}"
        bashio::log.info "Default interface: ${DEFAULT_IF}"
        bashio::log.info "Local subnet: ${LOCAL_SUBNET}"
        
        # Clear existing rules
        iptables -t nat -F POSTROUTING 2>/dev/null || true
        iptables -F FORWARD 2>/dev/null || true
        
        # Set up NAT and forwarding rules
        iptables -t nat -A POSTROUTING -s ${ZT_IP}/24 -d ${LOCAL_SUBNET} -j MASQUERADE
        iptables -t nat -A POSTROUTING -s ${ZT_IP}/24 -o ${DEFAULT_IF} -j MASQUERADE
        
        iptables -A FORWARD -i ${ZT_DEVICE} -o ${DEFAULT_IF} -j ACCEPT
        iptables -A FORWARD -i ${DEFAULT_IF} -o ${ZT_DEVICE} -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -i ${ZT_DEVICE} -d ${LOCAL_SUBNET} -j ACCEPT
        iptables -A FORWARD -s ${LOCAL_SUBNET} -o ${ZT_DEVICE} -j ACCEPT
        
        bashio::log.info "Gateway setup completed!"
        bashio::log.info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        bashio::log.info "🎉 GATEWAY SETUP COMPLETE!"
        bashio::log.info ""
        bashio::log.info "⚠️  IMPORTANT: You must configure a route in Zerotier Central:"
        bashio::log.info ""
        bashio::log.info "1. Go to https://my.zerotier.com"
        bashio::log.info "2. Click on your network"
        bashio::log.info "3. Scroll to 'Members' and authorize this device (check Auth?)"
        bashio::log.info "4. Scroll up to 'Settings' → 'Managed Routes'"
        bashio::log.info "5. Click 'Add Route' and enter:"
        bashio::log.info "   📍 Destination: ${LOCAL_SUBNET}"
        bashio::log.info "   📍 Via: ${ZT_IP} ← COPY THIS EXACTLY!"
        bashio::log.info "6. Click the checkmark to save"
        bashio::log.info ""
        bashio::log.info "Without this route, the gateway won't work!"
        bashio::log.info "Full documentation: See the DOCS tab in the add-on"
        bashio::log.info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        bashio::log.error "Could not get Zerotier network information"
    fi
fi

# Keep the service running and monitor
while true; do
    # Check if zerotier is still running
    if ! pgrep zerotier-one > /dev/null; then
        bashio::log.error "Zerotier daemon has stopped!"
        exit 1
    fi
    
    # Check network status every 30 seconds
    sleep 30
done