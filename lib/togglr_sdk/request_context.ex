defmodule TogglrSdk.RequestContext do
  @moduledoc """
  Request context for feature evaluation.

  Provides a fluent interface for building evaluation contexts with
  chainable methods for setting user attributes, country, and custom properties.
  """

  defstruct [:data]

  @type t :: %__MODULE__{
          data: map()
        }

  @doc """
  Creates a new empty request context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new()
      iex> context.data
      %{}

  """
  def new do
    %__MODULE__{data: %{}}
  end

  @doc """
  Creates a new request context with initial data.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new(%{"user.id" => "123"})
      iex> context.data
      %{"user.id" => "123"}

  """
  def new(data) when is_map(data) do
    %__MODULE__{data: data}
  end

  @doc """
  Sets the user ID in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> context.data["user.id"]
      "123"

  """
  def with_user_id(%__MODULE__{} = context, user_id) when is_binary(user_id) do
    %{context | data: Map.put(context.data, "user.id", user_id)}
  end

  @doc """
  Sets the country in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_country("US")
      iex> context.data["country"]
      "US"

  """
  def with_country(%__MODULE__{} = context, country) when is_binary(country) do
    %{context | data: Map.put(context.data, "country", country)}
  end

  @doc """
  Sets the user email in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_email("user@example.com")
      iex> context.data["user.email"]
      "user@example.com"

  """
  def with_user_email(%__MODULE__{} = context, email) when is_binary(email) do
    %{context | data: Map.put(context.data, "user.email", email)}
  end

  @doc """
  Sets whether the user is anonymous.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_anonymous(true)
      iex> context.data["user.anonymous"]
      true

  """
  def with_anonymous(%__MODULE__{} = context, anonymous) when is_boolean(anonymous) do
    %{context | data: Map.put(context.data, "user.anonymous", anonymous)}
  end

  @doc """
  Sets the region in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_region("us-west")
      iex> context.data["region"]
      "us-west"

  """
  def with_region(%__MODULE__{} = context, region) when is_binary(region) do
    %{context | data: Map.put(context.data, "region", region)}
  end

  @doc """
  Sets the city in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_city("San Francisco")
      iex> context.data["city"]
      "San Francisco"

  """
  def with_city(%__MODULE__{} = context, city) when is_binary(city) do
    %{context | data: Map.put(context.data, "city", city)}
  end

  @doc """
  Sets the device type in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_device_type("mobile")
      iex> context.data["device.type"]
      "mobile"

  """
  def with_device_type(%__MODULE__{} = context, device_type) when is_binary(device_type) do
    %{context | data: Map.put(context.data, "device.type", device_type)}
  end

  @doc """
  Sets the device manufacturer in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_manufacturer("Apple")
      iex> context.data["device.manufacturer"]
      "Apple"

  """
  def with_manufacturer(%__MODULE__{} = context, manufacturer) when is_binary(manufacturer) do
    %{context | data: Map.put(context.data, "device.manufacturer", manufacturer)}
  end

  @doc """
  Sets the operating system in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_os("iOS")
      iex> context.data["os"]
      "iOS"

  """
  def with_os(%__MODULE__{} = context, os) when is_binary(os) do
    %{context | data: Map.put(context.data, "os", os)}
  end

  @doc """
  Sets the operating system version in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_os_version("15.0")
      iex> context.data["os.version"]
      "15.0"

  """
  def with_os_version(%__MODULE__{} = context, version) when is_binary(version) do
    %{context | data: Map.put(context.data, "os.version", version)}
  end

  @doc """
  Sets the browser in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_browser("Safari")
      iex> context.data["browser"]
      "Safari"

  """
  def with_browser(%__MODULE__{} = context, browser) when is_binary(browser) do
    %{context | data: Map.put(context.data, "browser", browser)}
  end

  @doc """
  Sets the browser version in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_browser_version("15.0")
      iex> context.data["browser.version"]
      "15.0"

  """
  def with_browser_version(%__MODULE__{} = context, version) when is_binary(version) do
    %{context | data: Map.put(context.data, "browser.version", version)}
  end

  @doc """
  Sets the language in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_language("en-US")
      iex> context.data["language"]
      "en-US"

  """
  def with_language(%__MODULE__{} = context, language) when is_binary(language) do
    %{context | data: Map.put(context.data, "language", language)}
  end

  @doc """
  Sets the connection type in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_connection_type("wifi")
      iex> context.data["connection.type"]
      "wifi"

  """
  def with_connection_type(%__MODULE__{} = context, connection_type) when is_binary(connection_type) do
    %{context | data: Map.put(context.data, "connection.type", connection_type)}
  end

  @doc """
  Sets the user age in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_age(25)
      iex> context.data["user.age"]
      25

  """
  def with_age(%__MODULE__{} = context, age) when is_integer(age) and age >= 0 do
    %{context | data: Map.put(context.data, "user.age", age)}
  end

  @doc """
  Sets the user gender in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_gender("female")
      iex> context.data["user.gender"]
      "female"

  """
  def with_gender(%__MODULE__{} = context, gender) when is_binary(gender) do
    %{context | data: Map.put(context.data, "user.gender", gender)}
  end

  @doc """
  Sets the IP address in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_ip("192.168.1.1")
      iex> context.data["ip"]
      "192.168.1.1"

  """
  def with_ip(%__MODULE__{} = context, ip) when is_binary(ip) do
    %{context | data: Map.put(context.data, "ip", ip)}
  end

  @doc """
  Sets the application version in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_app_version("1.2.3")
      iex> context.data["app.version"]
      "1.2.3"

  """
  def with_app_version(%__MODULE__{} = context, version) when is_binary(version) do
    %{context | data: Map.put(context.data, "app.version", version)}
  end

  @doc """
  Sets the platform in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_platform("ios")
      iex> context.data["platform"]
      "ios"

  """
  def with_platform(%__MODULE__{} = context, platform) when is_binary(platform) do
    %{context | data: Map.put(context.data, "platform", platform)}
  end

  @doc """
  Sets a custom attribute in the context.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.set("plan", "premium")
      iex> context.data["plan"]
      "premium"

  """
  def set(%__MODULE__{} = context, key, value) when is_binary(key) do
    %{context | data: Map.put(context.data, key, value)}
  end

  @doc """
  Sets multiple attributes in the context.

  ## Examples

      iex> attrs = %{"plan" => "premium", "region" => "us-west"}
      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.set_many(attrs)
      iex> context.data["plan"]
      "premium"

  """
  def set_many(%__MODULE__{} = context, attrs) when is_map(attrs) do
    %{context | data: Map.merge(context.data, attrs)}
  end

  @doc """
  Returns the context data as a map.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> TogglrSdk.RequestContext.to_map(context)
      %{"user.id" => "123"}

  """
  def to_map(%__MODULE__{data: data}) do
    data
  end

  @doc """
  Returns the context data as a keyword list.

  ## Examples

      iex> context = TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123")
      iex> TogglrSdk.RequestContext.to_keyword_list(context)
      [{"user.id", "123"}]

  """
  def to_keyword_list(%__MODULE__{data: data}) do
    Map.to_list(data)
  end

  @doc """
  Checks if the context is empty.

  ## Examples

      iex> TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.empty?()
      true
      iex> TogglrSdk.RequestContext.new() |> TogglrSdk.RequestContext.with_user_id("123") |> TogglrSdk.RequestContext.empty?()
      false

  """
  def empty?(%__MODULE__{data: data}) do
    map_size(data) == 0
  end
end
