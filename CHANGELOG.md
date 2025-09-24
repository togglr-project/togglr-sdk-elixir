# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-22

### Added

- Initial release of Togglr SDK for Elixir
- Core client functionality for feature evaluation
- Request context with fluent interface for building evaluation contexts
- Built-in LRU caching with TTL using Cachex
- Configurable retry logic with exponential backoff
- Comprehensive error handling with specific exception types
- Telemetry support for monitoring and observability
- Complete test coverage
- Comprehensive documentation and examples
- Support for health checks
- Type specifications and documentation

### Features

- **Client**: Main SDK client with evaluation, health check, and lifecycle management
- **Config**: Flexible configuration system with method chaining
- **RequestContext**: Fluent interface for building evaluation contexts
- **Cache**: LRU cache with TTL for performance optimization
- **Exceptions**: Specific exception types for different error scenarios
- **BackoffConfig**: Configurable exponential backoff for retries
- **Telemetry**: Built-in telemetry events for monitoring

### Dependencies

- Tesla 1.4+ for HTTP client functionality
- Jason 1.4+ for JSON encoding/decoding
- Cachex 3.6+ for LRU caching
- Telemetry 1.0+ for observability
- ExUnit for testing
- Credo for code quality
- Dialyxir for static analysis
