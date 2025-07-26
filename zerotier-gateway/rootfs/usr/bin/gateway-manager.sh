#!/usr/bin/with-contenv bashio

CONFIG_FILE="/tmp/zerotier-gateway/config.json"
NETWORK_FILE="/tmp/zerotier-gateway/network.json"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    ENABLE_GATEWAY=$(jq -r '.enable_gateway' $CONFIG_FILE)
    LOCAL_SUBNET=$(jq -r '.local_subnet' $CONFIG_FILE)
else
    # Fallback to bashio config
    ENABLE_GATEWAY=$(bashio::config 'enable_gateway')
    LOCAL_SUBNET=$(bashio::config 'local_subnet')
fi

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
    
    if [[ "$ZT_DEVICE" != "null" && "$ZT_IP" != "null" && -n "$ZT_IP" && -n "$ZT_DEVICE" ]]; then
        # Get default interface
        DEFAULT_IF=$(ip route | grep default | awk '{print $5}' | head -n1)
        
        bashio::log.info "Setting up iptables rules..."
        bashio::log.info "Zerotier device: ${ZT_DEVICE}"
        bashio::log.info "Default interface: ${DEFAULT_IF}"
        bashio::log.info "Local subnet: ${LOCAL_SUBNET}"
        
        # Get ZeroTier subnet for cleanup
        ZT_SUBNET=$(echo "$ZT_IP" | cut -d'.' -f1-3).0/24
        
        # Clear only our specific rules (don't flush everything)
        # Remove previous zerotier-related rules if they exist
        iptables -t nat -D POSTROUTING -s ${ZT_SUBNET} -d ${LOCAL_SUBNET} -j MASQUERADE 2>/dev/null || true
        iptables -t nat -D POSTROUTING -s ${ZT_SUBNET} -o ${DEFAULT_IF} -j MASQUERADE 2>/dev/null || true
        
        iptables -D FORWARD -i ${ZT_DEVICE} -o ${DEFAULT_IF} -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -i ${DEFAULT_IF} -o ${ZT_DEVICE} -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -i ${ZT_DEVICE} -d ${LOCAL_SUBNET} -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -s ${LOCAL_SUBNET} -o ${ZT_DEVICE} -j ACCEPT 2>/dev/null || true
        
        # Get ZeroTier subnet (use the network range, not just our IP)
        # ZeroTier typically uses /24 for the managed routes
        ZT_SUBNET=$(echo "$ZT_IP" | cut -d'.' -f1-3).0/24
        
        bashio::log.info "ZeroTier subnet: ${ZT_SUBNET}"
        
        # Set up NAT and forwarding rules
        iptables -t nat -A POSTROUTING -s ${ZT_SUBNET} -d ${LOCAL_SUBNET} -j MASQUERADE
        iptables -t nat -A POSTROUTING -s ${ZT_SUBNET} -o ${DEFAULT_IF} -j MASQUERADE
        
        iptables -A FORWARD -i ${ZT_DEVICE} -o ${DEFAULT_IF} -j ACCEPT
        iptables -A FORWARD -i ${DEFAULT_IF} -o ${ZT_DEVICE} -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -i ${ZT_DEVICE} -d ${LOCAL_SUBNET} -j ACCEPT
        iptables -A FORWARD -s ${LOCAL_SUBNET} -o ${ZT_DEVICE} -j ACCEPT
        
        # IP forwarding is handled by Home Assistant privileged mode
        # Just check the status
        bashio::log.info "IP forwarding status: $(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 'unknown')"
        
        # Add debug info
        bashio::log.info "Running gateway debug..."
        /usr/bin/gateway-debug.sh || true
        
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
        if [[ -n "$ZT_DEVICE" && -z "$ZT_IP" ]]; then
            bashio::log.warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            bashio::log.warning "⚠️  DEVICE NOT AUTHORIZED IN ZEROTIER CENTRAL!"
            bashio::log.warning ""
            bashio::log.warning "Your device has joined the network but hasn't been authorized yet."
            bashio::log.warning "Device: ${ZT_DEVICE}"
            bashio::log.warning ""
            bashio::log.warning "To fix this:"
            bashio::log.warning "1. Go to https://my.zerotier.com"
            bashio::log.warning "2. Click on your network"
            bashio::log.warning "3. Scroll to 'Members' section"
            bashio::log.warning "4. Find this device and check the 'Auth?' checkbox"
            bashio::log.warning "5. An IP address will be assigned automatically"
            bashio::log.warning "6. Restart this addon after authorization"
            bashio::log.warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        else
            bashio::log.error "Could not get Zerotier network information"
        fi
    fi
fi

# Keep the service running and monitor
bashio::log.info "Gateway is initializing, please wait..."
rm -f /tmp/gateway-ready

while true; do
    # Check if zerotier is still running
    if ! pgrep zerotier-one > /dev/null; then
        bashio::log.error "Zerotier daemon has stopped!"
        exit 1
    fi
    
    # Run gateway monitor to check readiness
    /usr/bin/gateway-monitor.sh
    
    # Check network status every 10 seconds
    sleep 10
done