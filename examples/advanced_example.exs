#!/usr/bin/env elixir

# Advanced example of using Togglr SDK with custom configuration
# Run with: elixir examples/advanced_example.exs

defmodule AdvancedExample do
  @moduledoc """
  Advanced example demonstrating Togglr SDK with custom configuration,
  logging, metrics, and error handling.
  """

  def main do
    IO.puts("=== Togglr SDK Advanced Example ===")

    # Create a client with custom configuration
    case create_custom_client() do
      {:ok, client} ->
        try do
          run_advanced_example(client)
        after
          # Clean up resources
          TogglrSdk.Client.close(client)
        end

      {:error, reason} ->
        IO.puts("Failed to create client: #{inspect(reason)}")
    end
  end

  defp create_custom_client do
    # Create custom backoff configuration
    backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)

    # Create custom configuration
    config = TogglrSdk.Config.default("your-api-key")
    |> TogglrSdk.Config.with_base_url("https://api.togglr.com")
    |> TogglrSdk.Config.with_timeout(60000)
    |> TogglrSdk.Config.with_retries(5)
    |> TogglrSdk.Config.with_backoff(backoff)
    |> TogglrSdk.Config.with_cache(true, 2000, 120)
    |> TogglrSdk.Config.with_logger(Logger)

    TogglrSdk.Client.new(config)
  end

  defp run_advanced_example(client) do
    # Health check
    case TogglrSdk.Client.health_check(client) do
      {:ok, true} ->
        IO.puts("API is healthy")
      {:ok, false} ->
        IO.puts("API is not healthy, exiting")
        return
    end

    # Test multiple contexts
    contexts = [
      TogglrSdk.RequestContext.new()
      |> TogglrSdk.RequestContext.with_user_id("user1")
      |> TogglrSdk.RequestContext.with_country("US")
      |> TogglrSdk.RequestContext.set("plan", "premium"),

      TogglrSdk.RequestContext.new()
      |> TogglrSdk.RequestContext.with_user_id("user2")
      |> TogglrSdk.RequestContext.with_country("RU")
      |> TogglrSdk.RequestContext.set("plan", "basic"),

      TogglrSdk.RequestContext.new()
      |> TogglrSdk.RequestContext.with_user_id("user3")
      |> TogglrSdk.RequestContext.with_country("DE")
      |> TogglrSdk.RequestContext.set("plan", "enterprise")
      |> TogglrSdk.RequestContext.set("region", "europe")
    ]

    feature_keys = ["new_ui", "beta_feature", "premium_feature", "experimental_feature"]

    # Test each context
    Enum.with_index(contexts, 1)
    |> Enum.each(fn {context, index} ->
      IO.puts("\n--- Testing context #{index} ---")
      IO.puts("Context: #{inspect(TogglrSdk.RequestContext.to_map(context))}")

      Enum.each(feature_keys, fn feature_key ->
        case TogglrSdk.Client.evaluate(client, feature_key, context) do
          {:ok, result} ->
            if result.found do
              IO.puts("  #{feature_key}: enabled=#{result.enabled}, value=#{result.value}")
            else
              IO.puts("  #{feature_key}: not found")
            end

          {:error, reason} ->
            IO.puts("  #{feature_key}: error - #{inspect(reason)}")
        end

        # Test with default value
        case TogglrSdk.Client.is_enabled_or_default(client, feature_key, context, false) do
          {:ok, enabled} ->
            IO.puts("  #{feature_key} (with default): #{enabled}")

          {:error, reason} ->
            IO.puts("  #{feature_key} (with default): error - #{inspect(reason)}")
        end
      end)
    end)

    # Test caching
    IO.puts("\n--- Testing Caching ---")
    test_caching(client)

    # Test error handling
    IO.puts("\n--- Testing Error Handling ---")
    test_error_handling(client)

    # Test performance
    IO.puts("\n--- Testing Performance ---")
    test_performance(client)
  end

  defp test_caching(client) do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("cache_test_user")

    # First request (should hit API)
    start_time = System.monotonic_time(:millisecond)
    case TogglrSdk.Client.evaluate(client, "new_ui", context) do
      {:ok, result} ->
        elapsed = System.monotonic_time(:millisecond) - start_time
        IO.puts("First request: #{elapsed}ms, enabled=#{result.enabled}")

      {:error, reason} ->
        IO.puts("First request failed: #{inspect(reason)}")
    end

    # Second request (should hit cache)
    start_time = System.monotonic_time(:millisecond)
    case TogglrSdk.Client.evaluate(client, "new_ui", context) do
      {:ok, result} ->
        elapsed = System.monotonic_time(:millisecond) - start_time
        IO.puts("Second request (cached): #{elapsed}ms, enabled=#{result.enabled}")

      {:error, reason} ->
        IO.puts("Second request failed: #{inspect(reason)}")
    end
  end

  defp test_error_handling(client) do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("error_test_user")

    # Test feature not found
    case TogglrSdk.Client.is_enabled(client, "nonexistent_feature", context) do
      {:error, %TogglrSdk.Exceptions.FeatureNotFoundException{feature_key: feature_key}} ->
        IO.puts("Feature not found: #{feature_key}")

      {:error, reason} ->
        IO.puts("Unexpected error: #{inspect(reason)}")

      {:ok, _} ->
        IO.puts("Unexpected success")
    end

    # Test with default value
    case TogglrSdk.Client.is_enabled_or_default(client, "nonexistent_feature", context, false) do
      {:ok, enabled} ->
        IO.puts("Feature with default: #{enabled}")

      {:error, reason} ->
        IO.puts("Error with default: #{inspect(reason)}")
    end
  end

  defp test_performance(client) do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("perf_test_user")

    # Test multiple evaluations
    iterations = 10
    start_time = System.monotonic_time(:millisecond)

    for i <- 1..iterations do
      case TogglrSdk.Client.evaluate(client, "new_ui", context) do
        {:ok, result} ->
          elapsed = System.monotonic_time(:millisecond) - start_time
          IO.puts("  Attempt #{i}: #{elapsed}ms, enabled=#{result.enabled}, value=#{result.value}")

        {:error, reason} ->
          IO.puts("  Attempt #{i}: error - #{inspect(reason)}")
      end
    end

    total_time = System.monotonic_time(:millisecond) - start_time
    IO.puts("Total time for #{iterations} requests: #{total_time}ms")
    IO.puts("Average time per request: #{div(total_time, iterations)}ms")
  end
end

# Run the example
AdvancedExample.main()
