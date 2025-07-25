# Changelog

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