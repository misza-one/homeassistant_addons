# Changelog

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