#!/usr/bin/env elixir

# Advanced example of using Togglr SDK
# Run with: elixir examples/advanced_example.exs

defmodule AdvancedExample do
  @moduledoc """
  Advanced example demonstrating comprehensive Togglr SDK usage including
  error reporting and feature health monitoring.
  """

  def main do
    IO.puts("=== Togglr SDK Advanced Example ===")

    # Create a client with advanced configuration
    config = TogglrSdk.Config.default("your-api-key")
    |> TogglrSdk.Config.with_base_url("http://localhost:8090")
    |> TogglrSdk.Config.with_timeout(60000)
    |> TogglrSdk.Config.with_retries(5)
    |> TogglrSdk.Config.with_cache(true, 2000, 120)

    case TogglrSdk.Client.new(config) do
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
    # Create a context with user information
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("456")
    |> TogglrSdk.RequestContext.with_country("CA")
    |> TogglrSdk.RequestContext.with_user_email("user@example.ca")
    |> TogglrSdk.RequestContext.set("subscription", "premium")
    |> TogglrSdk.RequestContext.set("region", "north")

    IO.puts("Context: #{inspect(TogglrSdk.RequestContext.to_map(context))}")

    feature_key = "advanced_analytics"

    # Evaluate feature
    IO.puts("\n=== Feature Evaluation ===")
    case TogglrSdk.Client.evaluate(client, feature_key, context) do
      {:ok, result} ->
        IO.puts("Feature evaluation result:")
        IO.puts("  Found: #{result.found}")
        IO.puts("  Enabled: #{result.enabled}")
        IO.puts("  Value: #{result.value}")

      {:error, reason} ->
        IO.puts("Feature evaluation failed: #{inspect(reason)}")
    end

    # Test different error types
    IO.puts("\n=== Error Reporting Examples ===")

    error_examples = [
      {"timeout", "Service timeout after 10s", %{timeout_ms: 10000, service: "analytics"}},
      {"validation", "Invalid user data provided", %{field: "email", value: "invalid-email"}},
      {"service_unavailable", "External service is down", %{service: "database", region: "us-east-1"}},
      {"rate_limit", "Too many requests", %{limit: 100, current: 150, window: "1m"}}
    ]

    Enum.each(error_examples, fn {error_type, message, context_data} ->
      case TogglrSdk.Client.report_error(client, feature_key, error_type, message, context_data) do
        {:ok, {health, is_pending}} ->
          IO.puts("Reported #{error_type} error: pending=#{is_pending}")
          IO.puts("  Health: enabled=#{health.enabled}, auto_disabled=#{health.auto_disabled}")
          IO.puts("  Error rate: #{health.error_rate}, threshold: #{health.threshold}")

        {:error, reason} ->
          IO.puts("Failed to report #{error_type} error: #{inspect(reason)}")
      end
      IO.puts("")
    end)

    # Feature health monitoring
    IO.puts("=== Feature Health Monitoring ===")

    case TogglrSdk.Client.get_feature_health(client, feature_key) do
      {:ok, health} ->
        IO.puts("Feature: #{health.feature_key}")
        IO.puts("Environment: #{health.environment_key}")
        IO.puts("Enabled: #{health.enabled}")
        IO.puts("Auto Disabled: #{health.auto_disabled}")
        IO.puts("Error Rate: #{health.error_rate}")
        IO.puts("Threshold: #{health.threshold}")
        IO.puts("Last Error At: #{health.last_error_at}")
        IO.puts("Is Healthy: #{TogglrSdk.Models.FeatureHealth.healthy?(health)}")

      {:error, reason} ->
        IO.puts("Failed to get feature health: #{inspect(reason)}")
    end

    # Simple health check
    IO.puts("\n=== Simple Health Check ===")
    case TogglrSdk.Client.is_feature_healthy(client, feature_key) do
      {:ok, is_healthy} ->
        IO.puts("Feature #{feature_key} is healthy: #{is_healthy}")

      {:error, reason} ->
        IO.puts("Health check failed: #{inspect(reason)}")
    end

    # Multiple features health check
    IO.puts("\n=== Multiple Features Health Check ===")
    features = ["advanced_analytics", "new_ui", "beta_features", "experimental_api"]

    Enum.each(features, fn feature ->
      case TogglrSdk.Client.is_feature_healthy(client, feature) do
        {:ok, is_healthy} ->
          status = if is_healthy, do: "healthy", else: "unhealthy"
          IO.puts("Feature #{feature}: #{status}")

        {:error, reason} ->
          IO.puts("Feature #{feature}: error - #{inspect(reason)}")
      end
    end)

    # Health check
    IO.puts("\n=== System Health Check ===")
    case TogglrSdk.Client.health_check(client) do
      {:ok, healthy} ->
        IO.puts("System health: #{healthy}")

      {:error, reason} ->
        IO.puts("System health check failed: #{inspect(reason)}")
    end
  end
end

# Run the example
AdvancedExample.main()
