# Home Assistant Zerotier Gateway Add-on

Connect your Home Assistant to a Zerotier network and enable gateway functionality to access your entire local network from anywhere!

## Features

- 🌐 **Easy Zerotier Connection**: Join any Zerotier network with just the Network ID
- 🚪 **Gateway Functionality**: Access all devices on your local network through Zerotier
- 🔧 **Simple Configuration**: Set up everything through the Home Assistant UI
- 🔄 **Auto-Start**: Automatically connects on boot
- 📊 **Status Monitoring**: Built-in health checks and logging

## Installation

1. Add this repository to your Home Assistant Add-on Store:
   - Go to **Supervisor** → **Add-on Store** → **⋮** → **Repositories**
   - Add: `https://github.com/misza-one/homeassistant_addons`

2. Install the "Zerotier Gateway" add-on

3. Configure the add-on with your Zerotier Network ID

4. Start the add-on

5. Check the logs for setup instructions

## Configuration

| Option | Required | Description | Default |
|--------|----------|-------------|---------|
| `network_id` | Yes | Your 16-character Zerotier Network ID | - |
| `local_subnet` | No | Your local network subnet | `192.168.1.0/24` |
| `auth_token` | No | Zerotier auth token (optional) | - |
| `enable_gateway` | No | Enable gateway functionality | `true` |
| `auto_authorize` | No | Auto-authorize device (needs auth token) | `false` |
| `log_level` | No | Log level | `info` |

## Post-Installation Steps

After starting the add-on:

1. **Check the add-on logs** to find your Zerotier IP address (you'll need this!)

2. **Go to Zerotier Central**
   - Navigate to [my.zerotier.com](https://my.zerotier.com)
   - Click on your network

3. **Authorize your device**
   - Scroll to the "Members" section
   - Find your Home Assistant device
   - Check the **Auth?** checkbox
   - Wait for an IP to be assigned

4. **Configure the route** (IMPORTANT!)
   - In Zerotier Central, scroll to "Settings"
   - Find "Managed Routes"
   - Click "Add Route"
   - Configure:
     - **Destination**: Your local subnet (e.g., `192.168.1.0/24`)
     - **Via**: The Zerotier IP from step 1
   - Click the checkmark to save

5. **Verify it's working**
   - The route should show as active
   - You can now access local devices through Zerotier!

### Route Configuration Example

![Route Configuration](https://github.com/misza-one/homeassistant_addons/blob/main/images/route-config.png)

> **Note**: The "Via" IP must exactly match the Zerotier IP shown in your add-on logs!

## Support

If you have issues, please check the add-on logs first. Common problems:
- Device not appearing: Check your Network ID is correct
- Can't access local devices: Make sure the route is added in Zerotier Central
- Gateway not working: Check that your local subnet is configured correctly