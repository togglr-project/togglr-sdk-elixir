#!/usr/bin/env elixir

# Simple example of using Togglr SDK

defmodule SimpleExample do
  @moduledoc """
  Simple example demonstrating basic Togglr SDK usage.
  """

  def main do
    IO.puts("=== Togglr SDK Simple Example ===")

    # Create a client
    opts = [
        base_url: "https://localhost",
        timeout: 60000,
        retries: 5,
        cache_enabled: true,
        cache_max_size: 2000,
        cache_ttl: 120,
        insecure: true,
    ]
    case TogglrSdk.new_client("42b6f8f1-630c-400c-97bd-a3454a07f700", opts) do
      {:ok, client} ->
        try do
          run_example(client)
        after
          # Clean up resources
          TogglrSdk.Client.close(client)
        end

      {:error, reason} ->
        IO.puts("Failed to create client: #{inspect(reason)}")
    end
  end

  defp run_example(client) do
    # Create a context with user information using new with_* methods
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("123")
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
    |> TogglrSdk.RequestContext.with_age(25)
    |> TogglrSdk.RequestContext.with_gender("female")
    |> TogglrSdk.RequestContext.with_ip("192.168.1.1")
    |> TogglrSdk.RequestContext.with_app_version("1.2.3")
    |> TogglrSdk.RequestContext.with_platform("ios")
    |> TogglrSdk.RequestContext.set("plan", "premium")

    IO.puts("Context: #{inspect(TogglrSdk.RequestContext.to_map(context))}")

    # Health check
    case TogglrSdk.Client.health_check(client) do
      {:ok, true} ->
        IO.puts("API is healthy")
      {:ok, false} ->
        IO.puts("API is not healthy")
    end

    # Evaluate a feature
    case TogglrSdk.Client.evaluate(client, "new_ui", context) do
      {:ok, result} ->
        IO.puts("Feature evaluation result:")
        IO.puts("  Found: #{result.found}")
        IO.puts("  Enabled: #{result.enabled}")
        IO.puts("  Value: #{result.value}")

      {:error, reason} ->
        IO.puts("Feature evaluation failed: #{inspect(reason)}")
    end

    # Check if feature is enabled
    case TogglrSdk.Client.is_enabled(client, "new_ui", context) do
      {:ok, enabled} ->
        IO.puts("Feature is enabled: #{enabled}")

      {:error, reason} ->
        IO.puts("Error checking feature: #{inspect(reason)}")
    end

    # Check with default value
    case TogglrSdk.Client.is_enabled_or_default(client, "new_ui", context, false) do
      {:ok, enabled} ->
        IO.puts("Feature enabled (with default): #{enabled}")
    end

    # Report an error for a feature
    case TogglrSdk.Client.report_error(client, "new_ui", "timeout", "Service did not respond in 5s", %{service: "payment-gateway", timeout_ms: 5000}) do
      :ok ->
        IO.puts("Error reported successfully - queued for processing")

      {:error, reason} ->
        IO.puts("Failed to report error: #{inspect(reason)}")
    end

    # Get feature health
    case TogglrSdk.Client.get_feature_health(client, "new_ui") do
      {:ok, health} ->
        IO.puts("Feature health: enabled=#{health.enabled}, auto_disabled=#{health.auto_disabled}")
        IO.puts("Error rate: #{health.error_rate}, threshold: #{health.threshold}")

      {:error, reason} ->
        IO.puts("Failed to get feature health: #{inspect(reason)}")
    end

    # Simple health check
    case TogglrSdk.Client.is_feature_healthy(client, "new_ui") do
      {:ok, is_healthy} ->
        IO.puts("Feature new_ui is healthy: #{is_healthy}")

      {:error, reason} ->
        IO.puts("Failed to check feature health: #{inspect(reason)}")
    end

    # Example: Track events for analytics
    # Track impression event (recommended for each evaluation)
    impression_context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("user123")
    |> TogglrSdk.RequestContext.with_country("US")
    |> TogglrSdk.RequestContext.with_device_type("mobile")

    impression_event = TogglrSdk.new_track_event("A", :success)
    |> TogglrSdk.Models.TrackEvent.with_request_context(impression_context)
    |> TogglrSdk.Models.TrackEvent.with_dedup_key("impression-user123-new_ui")

    case TogglrSdk.Client.track_event(client, "new_ui", impression_event) do
      :ok ->
        IO.puts("Impression event tracked successfully")

      {:error, reason} ->
        IO.puts("Error tracking impression event: #{inspect(reason)}")
    end

    # Track conversion event with reward
    conversion_context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("user123")
    |> TogglrSdk.RequestContext.set("conversion_type", "purchase")
    |> TogglrSdk.RequestContext.set("order_value", 99.99)

    conversion_event = TogglrSdk.new_track_event("A", :success)
    |> TogglrSdk.Models.TrackEvent.with_reward(1.0)
    |> TogglrSdk.Models.TrackEvent.with_request_context(conversion_context)
    |> TogglrSdk.Models.TrackEvent.with_dedup_key("conversion-user123-new_ui")

    case TogglrSdk.Client.track_event(client, "new_ui", conversion_event) do
      :ok ->
        IO.puts("Conversion event tracked successfully")

      {:error, reason} ->
        IO.puts("Error tracking conversion event: #{inspect(reason)}")
    end

    # Track error event
    error_context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("user123")
    |> TogglrSdk.RequestContext.set("error_type", "timeout")
    |> TogglrSdk.RequestContext.set("error_message", "Service did not respond in 5s")

    error_event = TogglrSdk.new_track_event("B", :error)
    |> TogglrSdk.Models.TrackEvent.with_request_context(error_context)
    |> TogglrSdk.Models.TrackEvent.with_dedup_key("error-user123-new_ui")

    case TogglrSdk.Client.track_event(client, "new_ui", error_event) do
      :ok ->
        IO.puts("Error event tracked successfully")

      {:error, reason} ->
        IO.puts("Error tracking error event: #{inspect(reason)}")
    end
  end
end

# Run the example
SimpleExample.main()
