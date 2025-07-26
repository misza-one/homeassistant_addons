# Zerotier Gateway Documentation

## Overview

This add-on connects your Home Assistant to a Zerotier network and enables gateway functionality, allowing you to access your entire local network from anywhere through Zerotier.

## Data Persistence

Your ZeroTier identity and network configurations are stored in `/data/zerotier-one` which persists across addon restarts and updates. This ensures:
- Your device ID remains the same
- Network authorizations are preserved  
- No need to re-authorize after restarts

## Initial Setup

### Step 1: Create a Zerotier Network

1. Go to [my.zerotier.com](https://my.zerotier.com) and sign in
2. Click "Create A Network"
3. Copy the 16-character Network ID

### Step 2: Configure the Add-on

1. Install the add-on from the Home Assistant Add-on Store
2. Go to the Configuration tab
3. Enter your Network ID
4. Adjust other settings as needed:
   - `local_subnet`: Your local network range (default: 192.168.1.0/24)
   - `enable_gateway`: Keep this enabled for gateway functionality
   - `auth_token`: Optional, only needed for auto-authorization

### Step 3: Start the Add-on

1. Click "Start" on the add-on page
2. Check the logs to see your Zerotier IP address
3. Note this IP - you'll need it for route configuration

## Configuring Routes in Zerotier Central

**This is the most important step for gateway functionality!**

### Detailed Route Configuration Steps:

1. **Go to Zerotier Central**
   - Navigate to [my.zerotier.com](https://my.zerotier.com)
   - Click on your network

2. **Authorize Your Device**
   - Scroll down to the "Members" section
   - Find your Home Assistant device (look for the description or last seen time)
   - Check the "Auth?" checkbox to authorize it
   - Wait for the device to get an IP address

3. **Add the Route**
   - Scroll up to the "Settings" section
   - Find "Managed Routes" (usually in the middle of the page)
   - Click "Add Route"
   - Configure the route:
     - **Destination**: Enter your local subnet (e.g., `192.168.1.0/24`)
     - **Via**: Enter the Zerotier IP of your Home Assistant (shown in add-on logs)
   - Click the checkmark to save

4. **Verify the Route**
   - The route should appear in the list
   - Status should show as active
   - The "Via" IP should match your Home Assistant's Zerotier IP

### Understanding Routes

- **Destination**: This is your local network range where Home Assistant resides
  - Common examples: `192.168.1.0/24`, `192.168.0.0/24`, `10.0.0.0/24`
  - Must match the `local_subnet` in your add-on configuration
  
- **Via**: This is the Zerotier IP assigned to your Home Assistant
  - Found in the add-on logs after starting
  - Usually starts with `172.x.x.x` or `10.x.x.x`
  - This tells Zerotier to route traffic for your local network through Home Assistant

### Step 5: Configure Your Local Router (IMPORTANT!)

For devices on your local network to respond to ZeroTier connections, your router needs to know where to send the return traffic.

**Add a static route on your router:**
- **Destination Network**: `192.168.195.0/24` (or your ZeroTier network range)
- **Gateway/Next Hop**: `192.168.178.111` (your Home Assistant's local IP)
- **Interface**: LAN (if asked)

**Example for common routers:**

**Fritz!Box:**
1. Go to Home Network → Network → Network Settings → Static Routing Table
2. Click "New Route"
3. Enter:
   - Network: `192.168.195.0`
   - Subnet mask: `255.255.255.0`
   - Gateway: `192.168.178.111` (your HA IP)

**Asus/DD-WRT/OpenWRT:**
1. Go to Advanced Settings → LAN → Route
2. Add static route:
   - Network/Host IP: `192.168.195.0`
   - Netmask: `255.255.255.0`
   - Gateway: `192.168.178.111`

**Why this is needed:** Without this route, devices on your local network will try to send responses to ZeroTier IPs through your internet connection instead of through Home Assistant.

## Troubleshooting

### Device Not Appearing in Zerotier Central

- Check the Network ID is correct (exactly 16 characters)
- Restart the add-on
- Check logs for connection errors

### Can't Access Local Devices

1. **Verify Route Configuration**
   - Route destination matches your actual local subnet
   - Route via IP matches Home Assistant's Zerotier IP
   - Route is marked as active

2. **Check Firewall Settings**
   - Ensure Home Assistant host allows forwarding
   - No firewall blocking between Zerotier and local network

3. **Verify Gateway is Enabled**
   - Check add-on configuration has `enable_gateway: true`
   - Restart add-on after changing

### Common Network Ranges

Find your local subnet by checking your router or using these common ranges:

- `192.168.1.0/24` - Most common home network
- `192.168.0.0/24` - Alternative common range
- `10.0.0.0/24` - Some routers use this
- `172.16.0.0/24` - Less common in home networks

To find your exact subnet:
1. Check your Home Assistant IP address
2. If it's `192.168.1.50`, your subnet is likely `192.168.1.0/24`
3. If it's `10.0.0.50`, your subnet is likely `10.0.0.0/24`

## Security Considerations

- Only authorized devices can access your network through Zerotier
- The gateway only allows access from your Zerotier network to local network
- Consider using Zerotier's flow rules for additional security
- Regularly review authorized devices in Zerotier Central

## Advanced Configuration

### Multiple Subnets

If you have multiple subnets or VLANs, you can add multiple routes in Zerotier Central:

1. Add a route for each subnet
2. All routes should use the same "Via" IP (your Home Assistant Zerotier IP)
3. Update the add-on's iptables rules if needed (advanced users only)

### Custom Auth Token

To use auto-authorization:

1. Generate an API token at [my.zerotier.com/account](https://my.zerotier.com/account)
2. Add it to the add-on configuration
3. Enable `auto_authorize: true`

## Getting Help

- Check add-on logs for detailed error messages
- Ensure all steps above are followed exactly
- Common issues are usually route configuration errors
- The Zerotier IP in logs must match the "Via" IP in your route