defmodule TogglrSdk.Exceptions do
  @moduledoc """
  Custom exceptions for Togglr SDK.

  Provides specific exception types for different API error scenarios.
  """

  defmodule TogglrException do
    @moduledoc """
    Base exception for all Togglr SDK errors.
    """
    defexception [:message, :code]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil
          }

    def exception(message) do
      %__MODULE__{message: message, code: nil}
    end

    def exception(message, code) do
      %__MODULE__{message: message, code: code}
    end
  end

  defmodule UnauthorizedException do
    @moduledoc """
    Exception raised when API returns 401 Unauthorized.
    """
    defexception [:message, :code]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil
          }

    def exception(message \\ "Authentication required") do
      %__MODULE__{message: message, code: "unauthorized"}
    end
  end

  defmodule BadRequestException do
    @moduledoc """
    Exception raised when API returns 400 Bad Request.
    """
    defexception [:message, :code]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil
          }

    def exception(message \\ "Bad request") do
      %__MODULE__{message: message, code: "bad_request"}
    end
  end

  defmodule NotFoundException do
    @moduledoc """
    Exception raised when API returns 404 Not Found.
    """
    defexception [:message, :code]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil
          }

    def exception(message \\ "Resource not found") do
      %__MODULE__{message: message, code: "not_found"}
    end
  end

  defmodule FeatureNotFoundException do
    @moduledoc """
    Exception raised when a feature is not found.
    """
    defexception [:message, :feature_key]

    @type t :: %__MODULE__{
            message: String.t(),
            feature_key: String.t() | nil
          }

    def exception(feature_key) when is_binary(feature_key) do
      %__MODULE__{message: "Feature '#{feature_key}' not found", feature_key: feature_key}
    end

    def exception(message, feature_key) when is_binary(message) and is_binary(feature_key) do
      %__MODULE__{message: message, feature_key: feature_key}
    end
  end

  defmodule InternalServerException do
    @moduledoc """
    Exception raised when API returns 500 Internal Server Error.
    """
    defexception [:message, :code]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil
          }

    def exception(message \\ "Internal server error") do
      %__MODULE__{message: message, code: "internal"}
    end
  end

  defmodule TooManyRequestsException do
    @moduledoc """
    Exception raised when API returns 429 Too Many Requests.
    """
    defexception [:message, :code, :retry_after]

    @type t :: %__MODULE__{
            message: String.t(),
            code: String.t() | nil,
            retry_after: non_neg_integer() | nil
          }

    def exception(message \\ "Too many requests", retry_after \\ nil) do
      %__MODULE__{message: message, code: "too_many_requests", retry_after: retry_after}
    end
  end
end
