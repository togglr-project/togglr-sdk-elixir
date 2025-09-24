#!/usr/bin/env elixir

# Simple example of using Togglr SDK
# Run with: elixir examples/simple_example.exs

defmodule SimpleExample do
  @moduledoc """
  Simple example demonstrating basic Togglr SDK usage.
  """

  def main do
    IO.puts("=== Togglr SDK Simple Example ===")

    # Create a client with default configuration
    case TogglrSdk.new_client("your-api-key") do
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
    |> TogglrSdk.RequestContext.with_user_id("123")
    |> TogglrSdk.RequestContext.with_country("US")
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

      {:error, %TogglrSdk.Exceptions.FeatureNotFoundException{}} ->
        IO.puts("Feature not found")

      {:error, reason} ->
        IO.puts("Error checking feature: #{inspect(reason)}")
    end

    # Check with default value
    case TogglrSdk.Client.is_enabled_or_default(client, "new_ui", context, false) do
      {:ok, enabled} ->
        IO.puts("Feature enabled (with default): #{enabled}")

      {:error, reason} ->
        IO.puts("Error checking feature with default: #{inspect(reason)}")
    end
  end
end

# Run the example
SimpleExample.main()
