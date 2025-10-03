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
