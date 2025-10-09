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
