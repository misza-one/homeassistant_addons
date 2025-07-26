#!/usr/bin/with-contenv bashio

bashio::log.info "=== GATEWAY DEBUG INFO ==="

# Check IP forwarding
bashio::log.info "IP Forwarding status:"
cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "Cannot read IP forwarding status"

# Show network interfaces
bashio::log.info ""
bashio::log.info "Network interfaces:"
ip addr show | grep -E "^[0-9]+:|inet "

# Show routing table
bashio::log.info ""
bashio::log.info "Routing table:"
ip route

# Show NAT rules
bashio::log.info ""
bashio::log.info "NAT rules:"
iptables -t nat -L POSTROUTING -n -v

# Show FORWARD rules
bashio::log.info ""
bashio::log.info "FORWARD rules:"
iptables -L FORWARD -n -v | grep -E "(ztr|FORWARD)"

# Check ZeroTier status
bashio::log.info ""
bashio::log.info "ZeroTier status:"
zerotier-cli status

bashio::log.info ""
bashio::log.info "ZeroTier networks:"
zerotier-cli listnetworks

bashio::log.info "=== END DEBUG INFO ==="