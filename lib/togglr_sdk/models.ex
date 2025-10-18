defmodule TogglrSdk.Models do
  @moduledoc """
  Data models for Togglr SDK.

  Provides structures for error reporting and feature health monitoring.
  """

  defmodule ErrorReport do
    @moduledoc """
    Model for error reporting.

    Represents an error that occurred during feature execution.
    """

    @type t :: %__MODULE__{
            error_type: String.t(),
            error_message: String.t(),
            context: map()
          }

    defstruct [:error_type, :error_message, :context]

    @doc """
    Creates a new error report.

    ## Parameters

    - `error_type`: Type of error (e.g., "timeout", "validation", "service_unavailable")
    - `error_message`: Human-readable error message
    - `context`: Additional context data (default: %{})

    ## Examples

        iex> TogglrSdk.Models.ErrorReport.new("timeout", "Service timeout")
        %TogglrSdk.Models.ErrorReport{error_type: "timeout", error_message: "Service timeout", context: %{}}

    """
    def new(error_type, error_message, context \\ %{}) when is_binary(error_type) and is_binary(error_message) do
      %__MODULE__{
        error_type: error_type,
        error_message: error_message,
        context: context
      }
    end

    @doc """
    Converts the error report to a map for API requests.

    ## Examples

        iex> report = TogglrSdk.Models.ErrorReport.new("timeout", "Service timeout", %{service: "api"})
        iex> TogglrSdk.Models.ErrorReport.to_map(report)
        %{error_type: "timeout", error_message: "Service timeout", context: %{service: "api"}}

    """
    def to_map(%__MODULE__{} = report) do
      %{
        error_type: report.error_type,
        error_message: report.error_message,
        context: report.context
      }
    end
  end

  defmodule TrackEvent do
    @moduledoc """
    Model for tracking events for analytics.

    Represents an event that occurred during feature evaluation for analytics purposes.
    """

    alias TogglrSdk.RequestContext

    @type event_type :: :success | :failure | :error

    @type t :: %__MODULE__{
            variant_key: String.t(),
            event_type: event_type(),
            reward: float() | nil,
            context: RequestContext.t(),
            created_at: DateTime.t() | nil,
            dedup_key: String.t() | nil
          }

    defstruct [
      :variant_key,
      :event_type,
      :reward,
      :context,
      :created_at,
      :dedup_key
    ]

    @doc """
    Creates a new track event.

    ## Parameters

    - `variant_key`: The variant key that was evaluated
    - `event_type`: Type of event (:success, :failure, :error)
    - `opts`: Optional parameters

    ## Options

    - `:reward` - Optional reward value
    - `:context` - RequestContext instance (default: RequestContext.new())
    - `:created_at` - When the event occurred
    - `:dedup_key` - Deduplication key to prevent duplicate events

    ## Examples

        iex> TogglrSdk.Models.TrackEvent.new("A", :success)
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, context: %TogglrSdk.RequestContext{data: %{}}}

        iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
        iex> TogglrSdk.Models.TrackEvent.new("A", :success, reward: 1.0, context: context)
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, reward: 1.0, context: context}

    """
    def new(variant_key, event_type, opts \\ []) when is_binary(variant_key) and event_type in [:success, :failure, :error] do
      %__MODULE__{
        variant_key: variant_key,
        event_type: event_type,
        reward: Keyword.get(opts, :reward),
        context: Keyword.get(opts, :context, RequestContext.new()),
        created_at: Keyword.get(opts, :created_at),
        dedup_key: Keyword.get(opts, :dedup_key)
      }
    end

    @doc """
    Adds a reward value to the track event.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> TogglrSdk.Models.TrackEvent.with_reward(event, 1.0)
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, reward: 1.0}

    """
    def with_reward(%__MODULE__{} = event, reward) when is_number(reward) do
      %{event | reward: reward}
    end

    @doc """
    Adds context data to the track event using RequestContext.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> TogglrSdk.Models.TrackEvent.with_context(event, "user_id", "123")
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, context: %TogglrSdk.RequestContext{data: %{"user_id" => "123"}}}

    """
    def with_context(%__MODULE__{} = event, key, value) when is_binary(key) do
      updated_context = RequestContext.set(event.context, key, value)
      %{event | context: updated_context}
    end

    @doc """
    Adds multiple context key-value pairs to the track event using RequestContext.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> TogglrSdk.Models.TrackEvent.with_contexts(event, %{"user_id" => "123", "country" => "US"})
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, context: %TogglrSdk.RequestContext{data: %{"user_id" => "123", "country" => "US"}}}

    """
    def with_contexts(%__MODULE__{} = event, contexts) when is_map(contexts) do
      updated_context = RequestContext.set_many(event.context, contexts)
      %{event | context: updated_context}
    end

    @doc """
    Sets the context to a specific RequestContext instance.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
        iex> TogglrSdk.Models.TrackEvent.with_request_context(event, context)
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, context: context}

    """
    def with_request_context(%__MODULE__{} = event, %RequestContext{} = context) do
      %{event | context: context}
    end

    @doc """
    Sets the creation timestamp for the track event.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> now = DateTime.utc_now()
        iex> TogglrSdk.Models.TrackEvent.with_created_at(event, now)
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, created_at: now}

    """
    def with_created_at(%__MODULE__{} = event, created_at) when is_struct(created_at, DateTime) do
      %{event | created_at: created_at}
    end

    @doc """
    Sets the deduplication key for the track event.

    ## Examples

        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success)
        iex> TogglrSdk.Models.TrackEvent.with_dedup_key(event, "impression-user123")
        %TogglrSdk.Models.TrackEvent{variant_key: "A", event_type: :success, dedup_key: "impression-user123"}

    """
    def with_dedup_key(%__MODULE__{} = event, dedup_key) when is_binary(dedup_key) do
      %{event | dedup_key: dedup_key}
    end

    @doc """
    Converts the track event to a map for API requests.

    ## Examples

        iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
        iex> event = TogglrSdk.Models.TrackEvent.new("A", :success, reward: 1.0, context: context)
        iex> TogglrSdk.Models.TrackEvent.to_map(event)
        %{variant_key: "A", event_type: "success", reward: 1.0, context: %{"user.id" => "123"}}

    """
    def to_map(%__MODULE__{} = event) do
      base_map = %{
        variant_key: event.variant_key,
        event_type: Atom.to_string(event.event_type),
        context: RequestContext.to_map(event.context)
      }

      base_map
      |> maybe_put(:reward, event.reward)
      |> maybe_put(:created_at, event.created_at && DateTime.to_iso8601(event.created_at))
      |> maybe_put(:dedup_key, event.dedup_key)
    end

    defp maybe_put(map, _key, nil), do: map
    defp maybe_put(map, key, value), do: Map.put(map, key, value)
  end

  defmodule FeatureHealth do
    @moduledoc """
    Model for feature health information.

    Represents the health status of a feature including error rates and auto-disable status.
    """

    @type t :: %__MODULE__{
            feature_key: String.t(),
            environment_key: String.t(),
            enabled: boolean(),
            auto_disabled: boolean(),
            error_rate: float(),
            threshold: float(),
            last_error_at: String.t() | nil
          }

    defstruct [
      :feature_key,
      :environment_key,
      :enabled,
      :auto_disabled,
      :error_rate,
      :threshold,
      :last_error_at
    ]

    @doc """
    Creates a new feature health from individual parameters.

    ## Parameters

    - `opts`: Keyword list with health data

    ## Examples

        iex> TogglrSdk.Models.FeatureHealth.new(feature_key: "test", enabled: true)
        %TogglrSdk.Models.FeatureHealth{feature_key: "test", enabled: true, auto_disabled: false}

    """
    def new(opts) when is_list(opts) do
      %__MODULE__{
        feature_key: Keyword.get(opts, :feature_key),
        environment_key: Keyword.get(opts, :environment_key),
        enabled: Keyword.get(opts, :enabled, false),
        auto_disabled: Keyword.get(opts, :auto_disabled, false),
        error_rate: Keyword.get(opts, :error_rate, 0.0),
        threshold: Keyword.get(opts, :threshold, 0.0),
        last_error_at: Keyword.get(opts, :last_error_at)
      }
    end

    @doc """
    Creates a new feature health from API response data.

    ## Parameters

    - `data`: Map containing health data from API

    ## Examples

        iex> data = %{"feature_key" => "test", "enabled" => true, "auto_disabled" => false}
        iex> TogglrSdk.Models.FeatureHealth.from_map(data)
        %TogglrSdk.Models.FeatureHealth{feature_key: "test", enabled: true, auto_disabled: false}

    """
    def from_map(data) when is_map(data) do
      %__MODULE__{
        feature_key: Map.get(data, "feature_key"),
        environment_key: Map.get(data, "environment_key"),
        enabled: Map.get(data, "enabled", false),
        auto_disabled: Map.get(data, "auto_disabled", false),
        error_rate: Map.get(data, "error_rate", 0.0),
        threshold: Map.get(data, "threshold", 0.0),
        last_error_at: Map.get(data, "last_error_at")
      }
    end

    @doc """
    Checks if the feature is healthy.

    A feature is considered healthy if it's enabled and not auto-disabled.

    ## Examples

        iex> health = %TogglrSdk.Models.FeatureHealth{enabled: true, auto_disabled: false}
        iex> TogglrSdk.Models.FeatureHealth.healthy?(health)
        true

        iex> health = %TogglrSdk.Models.FeatureHealth{enabled: true, auto_disabled: true}
        iex> TogglrSdk.Models.FeatureHealth.healthy?(health)
        false

    """
    def healthy?(%__MODULE__{enabled: enabled, auto_disabled: auto_disabled}) do
      enabled and not auto_disabled
    end

    @doc """
    Converts the feature health to a map.

    ## Examples

        iex> health = %TogglrSdk.Models.FeatureHealth{feature_key: "test", enabled: true}
        iex> TogglrSdk.Models.FeatureHealth.to_map(health)
        %{feature_key: "test", enabled: true, auto_disabled: false, error_rate: 0.0, threshold: 0.0, last_error_at: nil}

    """
    def to_map(%__MODULE__{} = health) do
      %{
        feature_key: health.feature_key,
        environment_key: health.environment_key,
        enabled: health.enabled,
        auto_disabled: health.auto_disabled,
        error_rate: health.error_rate,
        threshold: health.threshold,
        last_error_at: health.last_error_at
      }
    end
  end
end
