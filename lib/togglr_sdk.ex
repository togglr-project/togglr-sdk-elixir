defmodule TogglrSdk do
  @moduledoc """
  Togglr SDK for Elixir.

  A feature flag management SDK that provides a simple interface for
  evaluating features with context-aware caching and retry logic.

  ## Quick Start

      # Create a client
      config = TogglrSdk.Config.default("your-api-key")
      {:ok, client} = TogglrSdk.Client.new(config)

      # Create a context
      context = TogglrSdk.RequestContext.new()
      |> TogglrSdk.RequestContext.with_user_id("123")
      |> TogglrSdk.RequestContext.with_country("US")

      # Evaluate a feature
      {:ok, result} = TogglrSdk.Client.evaluate(client, "new_ui", context)
      IO.puts("Feature enabled: true")

      # Check if feature is enabled
      {:ok, enabled} = TogglrSdk.Client.is_enabled(client, "new_ui", context)
      IO.puts("Feature enabled: true")

      # Check with default value
      {:ok, enabled} = TogglrSdk.Client.is_enabled_or_default(client, "new_ui", context, false)
      IO.puts("Feature enabled: true")

      # Health check
      {:ok, healthy} = TogglrSdk.Client.health_check(client)
      IO.puts("API healthy: true")

      # Clean up
      :ok = TogglrSdk.Client.close(client)

  ## Configuration

  The SDK can be configured with various options:

      config = TogglrSdk.Config.default("your-api-key")
      |> TogglrSdk.Config.with_base_url("https://api.togglr.com")
      |> TogglrSdk.Config.with_timeout(60000)
      |> TogglrSdk.Config.with_retries(5)
      |> TogglrSdk.Config.with_cache(true, 2000, 120)
      |> TogglrSdk.Config.with_logger(MyLogger)

  ## Caching

  The SDK includes built-in LRU caching with TTL:

      config = TogglrSdk.Config.default("your-api-key")
      |> TogglrSdk.Config.with_cache(true, 1000, 60)  # enabled, max_size, ttl_seconds

  ## Retry Logic

  Configure exponential backoff for retries:

      backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)  # base_delay, max_delay, multiplier
      config = TogglrSdk.Config.default("your-api-key")
      |> TogglrSdk.Config.with_backoff(backoff)

  ## Error Handling

  The SDK provides specific exceptions for different error scenarios:

      case TogglrSdk.Client.evaluate(client, "feature", context) do
        {:ok, result} ->
          # Handle success
        {:error, %TogglrSdk.Exceptions.FeatureNotFoundException{}} ->
          # Handle feature not found
        {:error, %TogglrSdk.Exceptions.UnauthorizedException{}} ->
          # Handle authentication error
        {:error, reason} ->
          # Handle other errors
      end

  ## Telemetry

  The SDK emits telemetry events for monitoring:

      defmodule MyTelemetry do
        def handle_event([:togglr_sdk, :evaluate, :start], measurements, metadata, _config) do
          # Handle evaluation start
        end

        def handle_event([:togglr_sdk, :evaluate, :stop], measurements, metadata, _config) do
          # Handle evaluation complete
        end
      end

      :telemetry.attach("togglr-sdk", [:togglr_sdk, :evaluate], &MyTelemetry.handle_event/4, nil)

  """

  @doc """
  Creates a new client with default configuration.

  This is a convenience function that creates a client with default settings.

  ## Parameters

  - `api_key`: Your Togglr API key

  ## Examples

      {:ok, client} = TogglrSdk.new_client("your-api-key")

  """
  def new_client(api_key) when is_binary(api_key) do
    config = TogglrSdk.Config.default(api_key)
    TogglrSdk.Client.new(config)
  end

  @doc """
  Creates a new client with custom configuration.

  ## Parameters

  - `api_key`: Your Togglr API key
  - `opts`: Configuration options

  ## Options

  - `:base_url` - API base URL (default: "http://localhost:8090")
  - `:timeout` - Request timeout in milliseconds (default: 30000)
  - `:retries` - Number of retries (default: 3)
  - `:cache_enabled` - Enable caching (default: true)
  - `:cache_max_size` - Maximum cache size (default: 1000)
  - `:cache_ttl` - Cache TTL in seconds (default: 60)
  - `:logger` - Logger module (default: Logger)

  ## Examples

      opts = [
        base_url: "https://api.togglr.com",
        timeout: 60000,
        retries: 5,
        cache_enabled: true,
        cache_max_size: 2000,
        cache_ttl: 120
      ]
      {:ok, client} = TogglrSdk.new_client("your-api-key", opts)

  """
  def new_client(api_key, opts) when is_binary(api_key) and is_list(opts) do
    config = TogglrSdk.Config.default(api_key)
    |> maybe_apply_opt(opts, :base_url, &TogglrSdk.Config.with_base_url/2)
    |> maybe_apply_opt(opts, :timeout, &TogglrSdk.Config.with_timeout/2)
    |> maybe_apply_opt(opts, :retries, &TogglrSdk.Config.with_retries/2)
    |> maybe_apply_opt(opts, :cache_enabled, &apply_cache_opts(&1, &2, opts))
    |> maybe_apply_opt(opts, :logger, &TogglrSdk.Config.with_logger/2)

    TogglrSdk.Client.new(config)
  end

  # Private helper functions

  defp maybe_apply_opt(config, opts, key, fun) do
    case Keyword.get(opts, key) do
      nil -> config
      value -> fun.(config, value)
    end
  end

  defp apply_cache_opts(config, cache_enabled, opts) do
    if cache_enabled do
      cache_max_size = Keyword.get(opts, :cache_max_size, 1000)
      cache_ttl = Keyword.get(opts, :cache_ttl, 60)
      TogglrSdk.Config.with_cache(config, true, cache_max_size, cache_ttl)
    else
      TogglrSdk.Config.with_cache(config, false, 0, 0)
    end
  end

  # Re-export models for convenience
  # alias TogglrSdk.Models.{ErrorReport, FeatureHealth}
end
