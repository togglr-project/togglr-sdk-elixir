defmodule TogglrSdk.Config do
  @moduledoc """
  Configuration module for Togglr SDK.

  Provides configuration options for the SDK client including API settings,
  caching, retry logic, and logging.
  """

  defstruct [
    :api_key,
    :base_url,
    :timeout,
    :retries,
    :cache_enabled,
    :cache_max_size,
    :cache_ttl,
    :backoff_config,
    :logger
  ]

  @type t :: %__MODULE__{
          api_key: String.t(),
          base_url: String.t(),
          timeout: non_neg_integer(),
          retries: non_neg_integer(),
          cache_enabled: boolean(),
          cache_max_size: non_neg_integer(),
          cache_ttl: non_neg_integer(),
          backoff_config: TogglrSdk.BackoffConfig.t(),
          logger: module()
        }

  @doc """
  Creates a default configuration with the given API key.

  ## Examples

      iex> config = TogglrSdk.Config.default("your-api-key")
      iex> config.api_key
      "your-api-key"

  """
  def default(api_key) when is_binary(api_key) do
    %__MODULE__{
      api_key: api_key,
      base_url: "http://localhost:8090",
      timeout: 30_000,
      retries: 3,
      cache_enabled: true,
      cache_max_size: 1000,
      cache_ttl: 60,
      backoff_config: TogglrSdk.BackoffConfig.default(),
      logger: Logger
    }
  end

  @doc """
  Updates the base URL for the API.

  ## Examples

      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_base_url("https://api.example.com")
      iex> config.base_url
      "https://api.example.com"

  """
  def with_base_url(%__MODULE__{} = config, base_url) when is_binary(base_url) do
    %{config | base_url: base_url}
  end

  @doc """
  Updates the timeout for HTTP requests in milliseconds.

  ## Examples

      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_timeout(60000)
      iex> config.timeout
      60000

  """
  def with_timeout(%__MODULE__{} = config, timeout) when is_integer(timeout) and timeout > 0 do
    %{config | timeout: timeout}
  end

  @doc """
  Updates the number of retries for failed requests.

  ## Examples

      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_retries(5)
      iex> config.retries
      5

  """
  def with_retries(%__MODULE__{} = config, retries) when is_integer(retries) and retries >= 0 do
    %{config | retries: retries}
  end

  @doc """
  Updates the backoff configuration for retry logic.

  ## Examples

      iex> backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)
      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_backoff(backoff)
      iex> config.backoff_config.base_delay
      0.5

  """
  def with_backoff(%__MODULE__{} = config, %TogglrSdk.BackoffConfig{} = backoff_config) do
    %{config | backoff_config: backoff_config}
  end

  @doc """
  Updates the cache configuration.

  ## Examples

      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_cache(true, 2000, 120)
      iex> config.cache_enabled
      true

  """
  def with_cache(%__MODULE__{} = config, enabled, max_size, ttl)
      when is_boolean(enabled) and is_integer(max_size) and is_integer(ttl) do
    %{config | cache_enabled: enabled, cache_max_size: max_size, cache_ttl: ttl}
  end

  @doc """
  Updates the logger module.

  ## Examples

      iex> config = TogglrSdk.Config.default("key") |> TogglrSdk.Config.with_logger(MyLogger)
      iex> config.logger
      MyLogger

  """
  def with_logger(%__MODULE__{} = config, logger) when is_atom(logger) do
    %{config | logger: logger}
  end
end
