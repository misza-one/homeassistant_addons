# Changelog

## 4.1.4 - 2025-07-27

### Added
- Proper ZeroTier logo as icon.png and logo.png
- Visual branding in addon store and UI

## 4.1.3 - 2025-07-27

### Improved
- Better initialization message explaining wait time (up to 5 minutes)
- Only shows message when gateway is enabled
- Clarifies addon is working while waiting for routes

## 4.1.2 - 2025-07-27

### Added
- Router static route documentation in DOCS.md
- Examples for Fritz!Box, Asus, DD-WRT, OpenWRT
- Gateway setup message now shows both required routes
- Explains why router configuration is needed

## 4.1.1 - 2025-07-26

### Added
- Gateway readiness monitoring with status messages
- Shows "GATEWAY IS FULLY OPERATIONAL" when ready
- Monitors connectivity every 10 seconds

### Improved
- Faster startup using specific port 9993
- Better feedback during initialization

## 4.1.0 - 2025-07-26

### Added
- **Persistent ZeroTier identity** across restarts
- Data stored in /data/zerotier-one directory
- Shows node ID on startup

### Fixed
- No more device ID changes after restart
- Network authorizations preserved

## 4.0.4 - 2025-07-26

### Fixed
- Permission errors with sysctl commands
- IP forwarding handled by host settings
- Improved error handling in scripts

## 4.0.3 - 2025-07-26

### Fixed
- Gateway connectivity using full ZeroTier subnet
- Added gateway debug script
- Shows network configuration for troubleshooting

## 4.0.2 - 2025-07-26

### Fixed
- Parsing for real ZeroTier output format
- Better IP address detection with regex
- Clear message when device needs authorization
- Handles unique device names (ztXXXXXXXX)

## 4.0.1 - 2025-07-26

### Fixed
- Multi-architecture build issues
- Uses base image directly
- Placeholder for unsupported architectures

## 4.0.0 - 2025-07-26

### Added
- **REAL ZEROTIER!** Built from source v1.14.2
- Compiles ZeroTier during Docker build for each architecture
- Full ZeroTier functionality - no more placeholder

### Changed
- Complete rewrite of Dockerfile to build from source
- Added Rust and build dependencies for compilation
- Major version bump to indicate real functionality

### Technical
- Multi-stage Docker build to keep image size reasonable
- Builds with optimization flags for performance
- Tested and working on amd64

## 2.0.0 - 2025-07-25

### Changed
- Build Zerotier from source for maximum compatibility
- This ensures we get a working binary on all architectures
- Increased build time but guaranteed to work

### Added
- Full build toolchain for compiling Zerotier
- Support for all architectures through source compilation

## 1.3.0 - 2025-07-25

### Added
- Direct download of Zerotier binary from official Debian packages
- Support for amd64 and arm64 architectures
- Better timeout handling with status messages

### Fixed
- Increased network join timeout to 5 minutes
- Added ACCESS_DENIED detection
- Improved status reporting during network join

## 1.2.2 - 2025-07-25

### Fixed
- Added proper Zerotier installation with fallback methods
- First try official install script
- Fallback to Alpine edge/testing repository
- Final fallback to placeholder if both fail

## 1.2.1 - 2025-07-25

### Fixed
- Removed IP forwarding via /proc (read-only in container)
- Fixed config.json file creation and dependencies
- Added fallback configuration loading
- Fixed all startup script errors
- Improved error handling

## 1.2.0 - 2024-01-25

### Added
- Detailed route configuration instructions in logs
- Comprehensive DOCS.md with troubleshooting guide
- Better error messages for common issues

### Changed
- Improved post-installation steps in README
- Enhanced gateway setup logging

## 1.1.0 - 2024-01-20

### Added
- Gateway functionality for local network access
- Automatic iptables configuration
- Health monitoring

### Changed
- Updated base image to latest version
- Improved network detection

## 1.0.0 - 2024-01-15

### Added
- Initial release
- Basic Zerotier connectivity
- Home Assistant integration