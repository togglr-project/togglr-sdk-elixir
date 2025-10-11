#!/usr/bin/env elixir

# Example of using TLS certificates for secure connection in Togglr Elixir SDK

# Create client with TLS configuration
{:ok, client} = TogglrSdk.new_client("42b6f8f1-630c-400c-97bd-a3454a07f700", [
  base_url: "https://localhost",
  # Use client certificate and key for mutual TLS authentication
  client_cert: "/path/to/client.crt",
  client_key: "/path/to/client.key",
  # Use custom CA certificate for server verification
  ca_cert: "/path/to/ca.crt",
  timeout: 5000,
  retries: 3
])

# Build request context with comprehensive user information
context = TogglrSdk.RequestContext.new()
|> TogglrSdk.RequestContext.with_user_id("user123")
|> TogglrSdk.RequestContext.with_user_email("user@example.com")
|> TogglrSdk.RequestContext.with_country("US")
|> TogglrSdk.RequestContext.with_region("us-west")
|> TogglrSdk.RequestContext.with_city("San Francisco")
|> TogglrSdk.RequestContext.with_device_type("mobile")
|> TogglrSdk.RequestContext.with_manufacturer("Apple")
|> TogglrSdk.RequestContext.with_os("iOS")
|> TogglrSdk.RequestContext.with_os_version("15.0")
|> TogglrSdk.RequestContext.with_browser("Safari")
|> TogglrSdk.RequestContext.with_browser_version("15.0")
|> TogglrSdk.RequestContext.with_language("en-US")
|> TogglrSdk.RequestContext.with_connection_type("wifi")
|> TogglrSdk.RequestContext.with_age(28)
|> TogglrSdk.RequestContext.with_gender("female")
|> TogglrSdk.RequestContext.with_ip("192.168.1.100")
|> TogglrSdk.RequestContext.with_app_version("2.1.0")
|> TogglrSdk.RequestContext.with_platform("ios")

# Evaluate a feature
feature_key = "new_ui"
case TogglrSdk.Client.evaluate(client, feature_key, context) do
  {:ok, result} ->
    if result.found do
      IO.puts("Feature #{feature_key}: enabled=#{result.enabled}, value=#{result.value}")
    else
      IO.puts("Feature #{feature_key} not found")
    end

  {:error, reason} ->
    IO.puts("Error evaluating feature #{feature_key}: #{inspect(reason)}")
end

# Use convenience method for boolean flags
case TogglrSdk.Client.is_enabled(client, feature_key, context) do
  {:ok, is_enabled} ->
    IO.puts("Feature #{feature_key} is enabled: #{is_enabled}")

  {:error, reason} ->
    IO.puts("Error checking if feature is enabled: #{inspect(reason)}")
end

# Health check
case TogglrSdk.Client.health_check(client) do
  {:ok, true} ->
    IO.puts("Health check passed")

  {:ok, false} ->
    IO.puts("Health check failed")

  {:error, reason} ->
    IO.puts("Health check error: #{inspect(reason)}")
end

# Example: Report an error for a feature
error_report = TogglrSdk.ErrorReport.new("timeout", "Service did not respond in 5s")
|> TogglrSdk.ErrorReport.with_context("service", "payment-gateway")
|> TogglrSdk.ErrorReport.with_context("timeout_ms", 5000)
|> TogglrSdk.ErrorReport.with_context("retry_count", 3)

case TogglrSdk.Client.report_error(client, feature_key, error_report) do
  :ok ->
    IO.puts("Error reported successfully - queued for processing")

  {:error, reason} ->
    IO.puts("Error reporting feature error: #{inspect(reason)}")
end

# Example: Get feature health status
case TogglrSdk.Client.get_feature_health(client, feature_key) do
  {:ok, feature_health} ->
    IO.puts("Feature health: enabled=#{feature_health.enabled}, auto_disabled=#{feature_health.auto_disabled}")

    if feature_health.error_rate do
      IO.puts("Error rate: #{feature_health.error_rate * 100}%")
    end

    if feature_health.last_error_at do
      IO.puts("Last error at: #{feature_health.last_error_at}")
    end

  {:error, reason} ->
    IO.puts("Error getting feature health: #{inspect(reason)}")
end

# Example: Check if feature is healthy
case TogglrSdk.Client.is_feature_healthy(client, feature_key) do
  {:ok, is_healthy} ->
    IO.puts("Feature is healthy: #{is_healthy}")

  {:error, reason} ->
    IO.puts("Error checking feature health: #{inspect(reason)}")
end

# Close the client
TogglrSdk.Client.close(client)
