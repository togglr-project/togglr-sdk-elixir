defmodule TogglrSdk.Client do
  @moduledoc """
  Main client for Togglr SDK.

  Provides methods for evaluating features, health checks, and managing
  the SDK lifecycle with caching and retry logic.
  """

  require Logger

  alias TogglrSdk.{Config, RequestContext, Cache, BackoffConfig}
  alias TogglrSdk.Exceptions

  # Generated API client
  alias SDKAPI.Api.Default, as: ApiClient
  alias SDKAPI.Model.{FeatureErrorReport, FeatureHealth}

  @type evaluation_result :: %{
          value: String.t(),
          enabled: boolean(),
          found: boolean()
        }

  @type t :: %__MODULE__{
          config: Config.t(),
          cache: pid() | nil,
          tesla_client: Tesla.Client.t()
        }

  defstruct [:config, :cache, :tesla_client]

  @doc """
  Creates a new Togglr client with the given configuration.

  ## Examples

      iex> config = TogglrSdk.Config.default("your-api-key")
      iex> {:ok, client} = TogglrSdk.Client.new(config)
      iex> is_pid(client.cache)
      true

  """
  def new(%Config{} = config) do
    # Start cache if enabled
    cache = if config.cache_enabled do
      case Cache.start_link(config.cache_max_size, config.cache_ttl) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
        {:error, reason} ->
          Logger.warning("Failed to start cache: #{inspect(reason)}")
          nil
      end
    else
      nil
    end

    # Create Tesla client with SSL configuration
    tesla_client = create_tesla_client(config)

    client = %__MODULE__{
      config: config,
      cache: cache,
      tesla_client: tesla_client
    }

    {:ok, client}
  end

  @doc """
  Evaluates a feature with the given context.

  ## Parameters

  - `feature_key`: The feature key to evaluate
  - `context`: The request context

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> {:ok, result} = client.evaluate("new_ui", context)
      iex> result.found
      true

  """
  def evaluate(%__MODULE__{} = client, feature_key, %RequestContext{} = context) do
    try do
      result = evaluate_with_retries(client, feature_key, context)
      {:ok, result}
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        {:error, e}
    end
  end

  @doc """
  Checks if a feature is enabled.

  ## Parameters

  - `feature_key`: The feature key to check
  - `context`: The request context

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> {:ok, enabled} = client.is_enabled("new_ui", context)
      iex> is_boolean(enabled)
      true

  """
  def is_enabled(%__MODULE__{} = client, feature_key, %RequestContext{} = context) do
    case evaluate(client, feature_key, context) do
      {:ok, %{found: false}} ->
        {:error, TogglrSdk.Exceptions.FeatureNotFoundException.exception(feature_key)}

      {:ok, %{enabled: enabled}} ->
        {:ok, enabled}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Checks if a feature is enabled with a default value.

  ## Parameters

  - `feature_key`: The feature key to check
  - `context`: The request context
  - `default`: Default value if feature is not found

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> {:ok, enabled} = client.is_enabled_or_default("new_ui", context, false)
      iex> is_boolean(enabled)
      true

  """
  def is_enabled_or_default(%__MODULE__{} = client, feature_key, %RequestContext{} = context, default) do
    case evaluate(client, feature_key, context) do
      {:ok, %{found: false}} ->
        {:ok, default}

      {:ok, %{enabled: enabled}} ->
        {:ok, enabled}

      {:error, _reason} ->
        {:ok, default}
    end
  end

  @doc """
  Performs a health check on the API.

  ## Examples

      iex> {:ok, healthy} = client.health_check()
      iex> is_boolean(healthy)
      true

  """
  def health_check(%__MODULE__{} = client) do
    try do
      case ApiClient.sdk_v1_health_get(client.tesla_client) do
        {:ok, %{"status" => "ok"}} -> {:ok, true}
        _ -> {:ok, false}
      end
    rescue
      _ ->
        {:ok, false}
    end
  end

  @doc """
  Closes the client and cleans up resources.

  ## Examples

      iex> :ok = client.close()
      :ok

  """
  def close(%__MODULE__{cache: nil}) do
    :ok
  end

  def close(%__MODULE__{cache: cache}) do
    GenServer.stop(cache)
    :ok
  end

  # Private functions

  defp create_tesla_client(config) do
    middleware = [
      {Tesla.Middleware.BaseUrl, config.base_url},
      {Tesla.Middleware.Headers, [{"Authorization", config.api_key}]},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Timeout, timeout: config.timeout}
    ]

    Tesla.client(middleware)
  end

  defp evaluate_with_retries(client, feature_key, context) do
    evaluate_with_retries(client, feature_key, context, 0)
  end

  defp evaluate_with_retries(client, feature_key, context, attempt) do
    try do
      evaluate_single(client, feature_key, context)
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        if attempt < client.config.retries and should_retry?(e) do
          delay = BackoffConfig.calculate_delay(client.config.backoff_config, attempt + 1)
          Process.sleep(trunc(delay * 1000))
          evaluate_with_retries(client, feature_key, context, attempt + 1)
        else
          reraise e, __STACKTRACE__
        end
    end
  end

  defp evaluate_single(client, feature_key, context) do
    # Check cache first
    cache_key = get_cache_key(feature_key, context)
    cached_result = if client.cache, do: Cache.get(cache_key), else: nil

    if cached_result do
      log(client, :debug, "Cache hit", %{feature_key: feature_key, cache_key: cache_key})
      cached_result
    else
      # Make API request using generated client
      request_body = RequestContext.to_map(context)

      case ApiClient.sdk_v1_features_feature_key_evaluate_post(client.tesla_client, feature_key, request_body) do
        {:ok, %{"feature_key" => _fk, "enabled" => enabled, "value" => value}} ->
          result = %{
            value: value,
            enabled: enabled,
            found: true
          }

          # Cache the result
          if client.cache do
            Cache.put(cache_key, result)
          end

          log(client, :debug, "Feature evaluated", %{
            feature_key: feature_key,
            enabled: enabled,
            value: value
          })

          result

        {:ok, _} ->
          %{value: "", enabled: false, found: false}

        {:error, %Tesla.Env{status: status, body: body}} ->
          handle_http_error(status, body, feature_key)

        {:error, %Tesla.Env{status: status}} ->
          handle_http_error(status, "", feature_key)

        {:error, reason} ->
          raise TogglrSdk.Exceptions.TogglrException, "Request failed: #{inspect(reason)}"
      end
    end
  end

  defp handle_http_error(401, _body, _feature_key) do
    raise TogglrSdk.Exceptions.UnauthorizedException
  end

  defp handle_http_error(400, _body, _feature_key) do
    raise TogglrSdk.Exceptions.BadRequestException
  end

  defp handle_http_error(404, _body, feature_key) do
    raise TogglrSdk.Exceptions.FeatureNotFoundException.exception(feature_key)
  end

  defp handle_http_error(429, _body, _feature_key) do
    raise TogglrSdk.Exceptions.TooManyRequestsException
  end

  defp handle_http_error(500, _body, _feature_key) do
    raise TogglrSdk.Exceptions.InternalServerException
  end

  defp handle_http_error(status, _body, _feature_key) do
    raise TogglrSdk.Exceptions.TogglrException, "HTTP #{status}"
  end

  defp should_retry?(%TogglrSdk.Exceptions.UnauthorizedException{}), do: false
  defp should_retry?(%TogglrSdk.Exceptions.BadRequestException{}), do: false
  defp should_retry?(%TogglrSdk.Exceptions.FeatureNotFoundException{}), do: false
  defp should_retry?(_), do: true

  defp get_cache_key(feature_key, context) do
    context_data = RequestContext.to_map(context)
    context_string = Jason.encode!(context_data)
    context_hash = :crypto.hash(:md5, context_string) |> Base.encode16(case: :lower)
    "#{feature_key}:#{context_hash}"
  end

  defp log(client, level, message, metadata \\ %{}) do
    if function_exported?(client.config.logger, level, 2) do
      client.config.logger.log(level, message, metadata)
    end
  end

  @doc """
  Reports an error for a feature.

  ## Parameters

  - `feature_key`: The feature key to report an error for
  - `error_type`: Type of error (e.g., "timeout", "validation", "service_unavailable")
  - `error_message`: Human-readable error message
  - `context`: Additional context data (default: %{})

  ## Returns

  - `:ok` - Success, error queued for processing
  - `{:error, reason}` - Error occurred

  ## Examples

      iex> :ok = client.report_error("feature_key", "timeout", "Service timeout")
      :ok

  """
  def report_error(%__MODULE__{} = client, feature_key, error_type, error_message, context \\ %{}) do
    try do
      report_error_with_retries(client, feature_key, error_type, error_message, context)
      :ok
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        {:error, e}
    end
  end

  @doc """
  Gets feature health information.

  ## Parameters

  - `feature_key`: The feature key to get health for

  ## Returns

  - `{:ok, health}` - Success, returns feature health
  - `{:error, reason}` - Error occurred

  ## Examples

      iex> {:ok, health} = client.get_feature_health("feature_key")
      iex> is_boolean(health.enabled)
      true

  """
  def get_feature_health(%__MODULE__{} = client, feature_key) do
    try do
      health = get_feature_health_with_retries(client, feature_key)
      {:ok, health}
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        {:error, e}
    end
  end

  @doc """
  Checks if a feature is healthy.

  ## Parameters

  - `feature_key`: The feature key to check

  ## Returns

  - `{:ok, boolean}` - Success, returns health status
  - `{:error, reason}` - Error occurred

  ## Examples

      iex> {:ok, healthy} = client.is_feature_healthy("feature_key")
      iex> is_boolean(healthy)
      true

  """
  def is_feature_healthy(%__MODULE__{} = client, feature_key) do
    case get_feature_health(client, feature_key) do
      {:ok, health} ->
        {:ok, TogglrSdk.Models.FeatureHealth.healthy?(health)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private methods for error reporting

  defp report_error_with_retries(client, feature_key, error_type, error_message, context) do
    error_report = TogglrSdk.Models.ErrorReport.new(error_type, error_message, context)

    report_error_with_retries(client, feature_key, error_report, 0)
  end

  defp report_error_with_retries(client, feature_key, error_report, attempt) do
    try do
      report_error_single(client, feature_key, error_report)
      :ok # Success
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        if attempt < client.config.retries and should_retry?(e) do
          delay = TogglrSdk.BackoffConfig.calculate_delay(client.config.backoff_config, attempt + 1)
          Process.sleep(trunc(delay * 1000))
          report_error_with_retries(client, feature_key, error_report, attempt + 1)
        else
          reraise e, __STACKTRACE__
        end
    end
  end

  defp report_error_single(client, feature_key, error_report) do
    # Convert our ErrorReport to generated FeatureErrorReport
    api_error_report = %FeatureErrorReport{
      error_type: error_report.error_type,
      error_message: error_report.error_message,
      context: error_report.context
    }

    case ApiClient.report_feature_error(client.tesla_client, feature_key, api_error_report) do
      {:ok, _} ->
        # Success - error queued for processing
        :ok

      {:error, %Tesla.Env{status: 401}} ->
        raise TogglrSdk.Exceptions.UnauthorizedException

      {:error, %Tesla.Env{status: 400}} ->
        raise TogglrSdk.Exceptions.BadRequestException

      {:error, %Tesla.Env{status: 404}} ->
        raise TogglrSdk.Exceptions.FeatureNotFoundException.exception(feature_key)

      {:error, %Tesla.Env{status: 500}} ->
        raise TogglrSdk.Exceptions.InternalServerException

      {:error, %Tesla.Env{status: status}} ->
        raise TogglrSdk.Exceptions.TogglrException, "HTTP #{status}"

      {:error, reason} ->
        raise TogglrSdk.Exceptions.TogglrException, "Request failed: #{inspect(reason)}"
    end
  end

  # Private methods for feature health

  defp get_feature_health_with_retries(client, feature_key) do
    get_feature_health_with_retries(client, feature_key, 0)
  end

  defp get_feature_health_with_retries(client, feature_key, attempt) do
    try do
      get_feature_health_single(client, feature_key)
    rescue
      e in [TogglrSdk.Exceptions.TogglrException] ->
        if attempt < client.config.retries and should_retry?(e) do
          delay = TogglrSdk.BackoffConfig.calculate_delay(client.config.backoff_config, attempt + 1)
          Process.sleep(trunc(delay * 1000))
          get_feature_health_with_retries(client, feature_key, attempt + 1)
        else
          reraise e, __STACKTRACE__
        end
    end
  end

  defp get_feature_health_single(client, feature_key) do
    case ApiClient.get_feature_health(client.tesla_client, feature_key) do
      {:ok, api_health} ->
        # Convert generated FeatureHealth to our FeatureHealth
        convert_feature_health(api_health)

      {:error, %Tesla.Env{status: 401}} ->
        raise TogglrSdk.Exceptions.UnauthorizedException

      {:error, %Tesla.Env{status: 400}} ->
        raise TogglrSdk.Exceptions.BadRequestException

      {:error, %Tesla.Env{status: 404}} ->
        raise TogglrSdk.Exceptions.FeatureNotFoundException.exception(feature_key)

      {:error, %Tesla.Env{status: 500}} ->
        raise TogglrSdk.Exceptions.InternalServerException

      {:error, %Tesla.Env{status: status}} ->
        raise TogglrSdk.Exceptions.TogglrException, "HTTP #{status}"

      {:error, reason} ->
        raise TogglrSdk.Exceptions.TogglrException, "Request failed: #{inspect(reason)}"
    end
  end

  defp convert_feature_health(api_health) do
    TogglrSdk.Models.FeatureHealth.new(
      feature_key: api_health.feature_key,
      environment_key: api_health.environment_key,
      enabled: api_health.enabled || false,
      auto_disabled: api_health.auto_disabled || false,
      error_rate: api_health.error_rate || 0,
      threshold: api_health.threshold || 0,
      last_error_at: api_health.last_error_at
    )
  end
end
