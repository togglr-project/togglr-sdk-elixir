defmodule TogglrSdk.RequestContextTest do
  use ExUnit.Case
  doctest TogglrSdk.RequestContext

  test "creates a new empty context" do
    context = TogglrSdk.RequestContext.new()
    assert context.data == %{}
    assert TogglrSdk.RequestContext.empty?(context)
  end

  test "creates a new context with initial data" do
    data = %{"user.id" => "123", "country" => "US"}
    context = TogglrSdk.RequestContext.new(data)
    assert context.data == data
    refute TogglrSdk.RequestContext.empty?(context)
  end

  test "sets user ID" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("123")

    assert context.data["user.id"] == "123"
  end

  test "sets country" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_country("US")

    assert context.data["country"] == "US"
  end

  test "sets custom attribute" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.set("plan", "premium")

    assert context.data["plan"] == "premium"
  end

  test "sets multiple attributes" do
    attrs = %{"plan" => "premium", "region" => "us-west"}
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.set_many(attrs)

    assert context.data["plan"] == "premium"
    assert context.data["region"] == "us-west"
  end

  test "converts to map" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("123")
    |> TogglrSdk.RequestContext.with_country("US")

    expected = %{"user.id" => "123", "country" => "US"}
    assert TogglrSdk.RequestContext.to_map(context) == expected
  end

  test "converts to keyword list" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("123")
    |> TogglrSdk.RequestContext.with_country("US")

    result = TogglrSdk.RequestContext.to_keyword_list(context)
    assert {"user.id", "123"} in result
    assert {"country", "US"} in result
    assert length(result) == 2
  end

  test "chains multiple operations" do
    context = TogglrSdk.RequestContext.new()
    |> TogglrSdk.RequestContext.with_user_id("123")
    |> TogglrSdk.RequestContext.with_country("US")
    |> TogglrSdk.RequestContext.set("plan", "premium")
    |> TogglrSdk.RequestContext.set("region", "us-west")

    assert context.data["user.id"] == "123"
    assert context.data["country"] == "US"
    assert context.data["plan"] == "premium"
    assert context.data["region"] == "us-west"
  end
end
