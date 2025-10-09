# Togglr SDK for Elixir

[![Hex.pm](https://img.shields.io/hexpm/v/togglr_sdk.svg)](https://hex.pm/packages/togglr_sdk)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/togglr_sdk/)
[![Build Status](https://img.shields.io/travis/togglr/togglr-sdk-elixir.svg)](https://travis-ci.org/togglr/togglr-sdk-elixir)

Official Elixir SDK for Togglr feature flag management system. This SDK provides a simple and efficient way to evaluate feature flags in your Elixir applications with built-in caching, retry logic, and error handling.

## Features

- **Simple API**: Easy-to-use interface for evaluating feature flags
- **Context-aware**: Support for user attributes, country, and custom properties
- **Built-in Caching**: LRU cache with TTL for improved performance
- **Retry Logic**: Configurable exponential backoff for failed requests
- **Error Handling**: Specific exceptions for different error scenarios
- **Telemetry**: Built-in telemetry events for monitoring and observability
- **Type Safety**: Comprehensive type specifications and documentation

## Installation

Add `togglr_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:togglr_sdk, "~> 1.0"}
  ]
end
```

Then run `mix deps.get` to install the dependencies.

## Quick Start

```elixir
# Create a client
{:ok, client} = TogglrSdk.new_client("your-api-key")

# Create a context
context = TogglrSdk.RequestContext.new()
|> TogglrSdk.RequestContext.with_user_id("123")
|> TogglrSdk.RequestContext.with_country("US")

# Evaluate a feature
{:ok, result} = TogglrSdk.Client.evaluate(client, "new_ui", context)
IO.puts("Feature enabled: #{result.enabled}")

# Check if feature is enabled
{:ok, enabled} = TogglrSdk.Client.is_enabled(client, "new_ui", context)
IO.puts("Feature enabled: #{enabled}")

# Check with default value
{:ok, enabled} = TogglrSdk.Client.is_enabled_or_default(client, "new_ui", context, false)
IO.puts("Feature enabled: #{enabled}")

# Health check
{:ok, healthy} = TogglrSdk.Client.health_check(client)
IO.puts("API healthy: #{healthy}")

# Clean up
:ok = TogglrSdk.Client.close(client)
```

## Configuration

The SDK can be configured with various options:

```elixir
# Using the convenience function
opts = [
  base_url: "https://api.togglr.com",
  timeout: 60000,
  retries: 5,
  cache_enabled: true,
  cache_max_size: 2000,
  cache_ttl: 120,
  insecure: true  # Skip SSL verification for self-signed certificates
]
{:ok, client} = TogglrSdk.new_client("your-api-key", opts)

# Or using the configuration module directly
config = TogglrSdk.Config.default("your-api-key")
|> TogglrSdk.Config.with_base_url("https://api.togglr.com")
|> TogglrSdk.Config.with_timeout(60000)
|> TogglrSdk.Config.with_retries(5)
|> TogglrSdk.Config.with_cache(true, 2000, 120)
|> TogglrSdk.Config.with_logger(MyLogger)

{:ok, client} = TogglrSdk.Client.new(config)
```

### Configuration Options

- `api_key` - Your Togglr API key (required)
- `base_url` - API base URL (default: "http://localhost:8090")
- `timeout` - Request timeout in milliseconds (default: 30000)
- `retries` - Number of retries for failed requests (default: 3)
- `cache_enabled` - Enable caching (default: true)
- `cache_max_size` - Maximum number of entries in cache (default: 1000)
- `cache_ttl` - Cache TTL in seconds (default: 60)
- `logger` - Logger module (default: Logger)

## Usage

### Request Context

The request context allows you to provide user attributes and other data for feature evaluation:

```elixir
context = TogglrSdk.RequestContext.new()
|> TogglrSdk.RequestContext.with_user_id("123")
|> TogglrSdk.RequestContext.with_country("US")
|> TogglrSdk.RequestContext.set("plan", "premium")
|> TogglrSdk.RequestContext.set("region", "us-west")
|> TogglrSdk.RequestContext.set_many(%{
  "user.role" => "admin",
  "user.team" => "engineering"
})
```

### Feature Evaluation

```elixir
# Evaluate a feature
{:ok, result} = TogglrSdk.Client.evaluate(client, "new_ui", context)
# result = %{value: "enabled", enabled: true, found: true}

# Check if feature is enabled
{:ok, enabled} = TogglrSdk.Client.is_enabled(client, "new_ui", context)
# enabled = true

# Check with default value
{:ok, enabled} = TogglrSdk.Client.is_enabled_or_default(client, "new_ui", context, false)
# enabled = true
```

## Error Reporting and Auto-Disable

The SDK supports reporting errors for features, which can trigger automatic disabling based on error rates:

```elixir
# Report an error for a feature
:ok = TogglrSdk.Client.report_error(
  client,
  "feature_key",
  "timeout",
  "Service did not respond in 5s",
  %{service: "payment-gateway", timeout_ms: 5000}
)

IO.puts("Error reported successfully - queued for processing")
```

### Error Types

Supported error types:
- `timeout` - Service timeout
- `validation` - Data validation error
- `service_unavailable` - External service unavailable
- `rate_limit` - Rate limit exceeded
- `network` - Network connectivity issue
- `internal` - Internal application error

### Context Data

You can provide additional context with error reports:

```elixir
context = %{
  service: "payment-gateway",
  timeout_ms: 5000,
  user_id: "user123",
  region: "us-east-1"
}

:ok = TogglrSdk.Client.report_error(
  client,
  "feature_key",
  "timeout",
  "Service timeout",
  context
)
```

## Feature Health Monitoring

Monitor the health status of features:

```elixir
# Get detailed health information
{:ok, health} = TogglrSdk.Client.get_feature_health(client, "feature_key")

IO.puts("Feature: #{health.feature_key}")
IO.puts("Enabled: #{health.enabled}")
IO.puts("Auto Disabled: #{health.auto_disabled}")
IO.puts("Error Rate: #{health.error_rate}")
IO.puts("Threshold: #{health.threshold}")
IO.puts("Last Error At: #{health.last_error_at}")

# Simple health check
{:ok, is_healthy} = TogglrSdk.Client.is_feature_healthy(client, "feature_key")
IO.puts("Feature is healthy: #{is_healthy}")
```

### FeatureHealth Model

The `TogglrSdk.Models.FeatureHealth` struct provides:

- `feature_key` - The feature identifier
- `environment_key` - The environment identifier
- `enabled` - Whether the feature is enabled
- `auto_disabled` - Whether the feature was auto-disabled due to errors
- `error_rate` - Current error rate (0.0 to 1.0)
- `threshold` - Error rate threshold for auto-disable
- `last_error_at` - Timestamp of the last error
- `healthy?/1` - Function to check if feature is healthy

### ErrorReport Model

The `TogglrSdk.Models.ErrorReport` struct provides:

- `error_type` - Type of error
- `error_message` - Human-readable error message
- `context` - Additional context data

```elixir
# Create an error report
error_report = TogglrSdk.Models.ErrorReport.new(
  "timeout",
  "Service timeout",
  %{service: "api", timeout_ms: 5000}
)

# Convert to map for API requests
error_data = TogglrSdk.Models.ErrorReport.to_map(error_report)
```

### Error Handling

The SDK provides specific exceptions for different error scenarios:

```elixir
case TogglrSdk.Client.evaluate(client, "feature", context) do
  {:ok, result} ->
    # Handle success
    process_result(result)

  {:error, %TogglrSdk.Exceptions.FeatureNotFoundException{feature_key: feature_key}} ->
    # Handle feature not found
    IO.puts("Feature '#{feature_key}' not found")

  {:error, %TogglrSdk.Exceptions.UnauthorizedException{}} ->
    # Handle authentication error
    IO.puts("Authentication failed")

  {:error, %TogglrSdk.Exceptions.BadRequestException{}} ->
    # Handle bad request
    IO.puts("Invalid request")

  {:error, reason} ->
    # Handle other errors
    IO.puts("Error: #{inspect(reason)}")
end
```

## Caching

The SDK includes built-in LRU caching with TTL for improved performance:

```elixir
# Enable caching with custom settings
config = TogglrSdk.Config.default("your-api-key")
|> TogglrSdk.Config.with_cache(true, 2000, 120)  # enabled, max_size, ttl_seconds

{:ok, client} = TogglrSdk.Client.new(config)
```

Cache statistics are available through the cache module:

```elixir
# Get cache statistics
stats = TogglrSdk.Cache.stats()
# stats = %{size: 150, hits: 1200, misses: 300}
```

## Retry Logic

Configure exponential backoff for retries:

```elixir
# Create custom backoff configuration
backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)  # base_delay, max_delay, multiplier

config = TogglrSdk.Config.default("your-api-key")
|> TogglrSdk.Config.with_backoff(backoff)
|> TogglrSdk.Config.with_retries(5)

{:ok, client} = TogglrSdk.Client.new(config)
```

## Telemetry

The SDK emits telemetry events for monitoring and observability:

```elixir
defmodule MyTelemetry do
  def handle_event([:togglr_sdk, :evaluate, :start], measurements, metadata, _config) do
    # Handle evaluation start
    IO.puts("Starting feature evaluation: #{metadata.feature_key}")
  end

  def handle_event([:togglr_sdk, :evaluate, :stop], measurements, metadata, _config) do
    # Handle evaluation complete
    IO.puts("Feature evaluation completed in #{measurements.duration}ms")
  end

  def handle_event([:togglr_sdk, :evaluate, :exception], measurements, metadata, _config) do
    # Handle evaluation error
    IO.puts("Feature evaluation failed: #{inspect(metadata.kind)}")
  end
end

# Attach telemetry handler
:telemetry.attach("togglr-sdk", [:togglr_sdk, :evaluate], &MyTelemetry.handle_event/4, nil)
```

## Development

### Prerequisites

- Elixir 1.14 or later
- Mix 1.14 or later
- OpenAPI Generator CLI (for client generation)

### Setup

```bash
# Clone the repository
git clone https://github.com/togglr/togglr-sdk-elixir.git
cd togglr-sdk-elixir

# Install dependencies
mix deps.get

# Run tests
mix test

# Run linting
mix credo --strict
mix dialyzer

# Format code
mix format

# Generate documentation
mix docs
```

### OpenAPI Client Generation

This project automatically generates the API client from OpenAPI specifications. See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed information about the generation process.

Quick commands:
```bash
# Generate API client
make generate

# Full regeneration (clean + generate)
make regenerate

# Apply modifications only
make post-generate
```

### Building

```bash
# Build the package
mix hex.build

# Publish to Hex (requires authentication)
mix hex.publish
```

## Examples

See the `examples/` directory for complete examples:

- `simple_example.exs` - Basic usage example
- `advanced_example.exs` - Advanced configuration and error handling

Run examples with:

```bash
elixir examples/simple_example.exs
elixir examples/advanced_example.exs
```

## Requirements

- Elixir 1.14+
- OTP 24+
- Tesla 1.4+
- Jason 1.4+
- Cachex 3.6+
- Telemetry 1.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For support, please open an issue on GitHub or contact the Togglr team.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
