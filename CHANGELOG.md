# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-01-02

### Changed
- **Error Reporting API Simplification**: Updated error reporting to use asynchronous processing
  - `report_error/4` and `report_error/5` - Now returns `:ok` (simplified API)
  - 202 responses now always indicate successful queuing for processing (no more pending changes)
  - Removed `is_pending` return value as it's no longer needed

### Added
- **Error Reporting**: New methods for reporting feature execution errors
  - `report_error/4` and `report_error/5` - Report a single error with automatic retries, returns `:ok`
  - Support for different error types (timeout, validation, service_unavailable, etc.)
  - Context data support for error reports

- **Feature Health Monitoring**: New methods for monitoring feature health
  - `get_feature_health/2` - Get detailed health status with automatic retries
  - `is_feature_healthy/2` - Simple boolean health check

- **New Models**:
  - `TogglrSdk.Models.ErrorReport` - Structure for error reporting
  - `TogglrSdk.Models.FeatureHealth` - Structure for health monitoring with detailed information
  - Support for 202 responses with `is_pending` boolean return value

- **Enhanced Examples**:
  - Updated simple example with error reporting and health monitoring
  - New advanced example demonstrating comprehensive usage
  - Error reporting examples with different error types
  - Health monitoring examples

### Changed
- **Retry Logic**: All methods now automatically apply retries based on client configuration
- **202 Response Handling**: 202 responses now return `{:ok, {health, is_pending}}` with `is_pending = true` instead of error
- Updated README with comprehensive documentation for new features
- Enhanced error handling and response processing
- Improved example structure and organization

### Technical Details
- Manual implementation of API endpoints (no OpenAPI client generation)
- Automatic retry logic based on client configuration
- Proper handling of 202 responses with pending change indication
- Backward compatible - no breaking changes to existing API
- Full Elixir-style function naming and conventions
- Comprehensive type specifications and documentation

## [1.0.0] - 2024-01-XX

### Added
- Initial release of togglr-sdk-elixir
- Support for feature flag evaluation
- Request context with predefined attributes
- Caching support with TTL
- Retry logic with exponential backoff
- Health check functionality
- Comprehensive error handling
- Examples and documentation
- ExUnit test suite
- Credo code style checking
- Dialyxir type checking
- Coverage reporting

### Features
- **Client**: Main client for feature flag evaluation
- **RequestContext**: Builder pattern for request context
- **Configuration**: Flexible configuration with method chaining
- **Caching**: LRU cache with TTL for evaluation results
- **Retries**: Exponential backoff retry logic
- **Logging**: Pluggable logging interface
- **Telemetry**: Built-in telemetry events for monitoring
- **Error Handling**: Comprehensive error types and handling