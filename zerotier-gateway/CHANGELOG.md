# Changelog

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