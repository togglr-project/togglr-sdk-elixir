defmodule TogglrSdk.BackoffConfig do
  @moduledoc """
  Configuration for exponential backoff retry logic.

  Provides configurable backoff parameters for retrying failed requests
  with exponential delay between attempts.
  """

  defstruct [:base_delay, :max_delay, :multiplier]

  @type t :: %__MODULE__{
          base_delay: float(),
          max_delay: float(),
          multiplier: float()
        }

  @doc """
  Creates a new backoff configuration.

  ## Parameters

  - `base_delay`: Initial delay in seconds (default: 0.5)
  - `max_delay`: Maximum delay in seconds (default: 10.0)
  - `multiplier`: Multiplier for each retry (default: 1.5)

  ## Examples

      iex> backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)
      iex> backoff.base_delay
      0.5

  """
  def new(base_delay \\ 0.5, max_delay \\ 10.0, multiplier \\ 1.5)
      when is_float(base_delay) and is_float(max_delay) and is_float(multiplier) do
    %__MODULE__{
      base_delay: base_delay,
      max_delay: max_delay,
      multiplier: multiplier
    }
  end

  @doc """
  Creates a default backoff configuration.

  ## Examples

      iex> backoff = TogglrSdk.BackoffConfig.default()
      iex> backoff.base_delay
      0.5

  """
  def default do
    new()
  end

  @doc """
  Calculates the delay for a given attempt number.

  Uses exponential backoff formula: min(max_delay, base_delay * (multiplier ^ attempt))

  ## Examples

      iex> backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)
      iex> TogglrSdk.BackoffConfig.calculate_delay(backoff, 0)
      0.0
      iex> TogglrSdk.BackoffConfig.calculate_delay(backoff, 1)
      0.5
      iex> TogglrSdk.BackoffConfig.calculate_delay(backoff, 2)
      0.75

  """
  def calculate_delay(%__MODULE__{} = config, attempt) when is_integer(attempt) and attempt >= 0 do
    if attempt == 0 do
      0.0
    else
      delay = config.base_delay * :math.pow(config.multiplier, attempt - 1)
      min(delay, config.max_delay)
    end
  end
end
