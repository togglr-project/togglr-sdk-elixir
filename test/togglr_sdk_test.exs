defmodule TogglrSdkTest do
  use ExUnit.Case
  doctest TogglrSdk

  test "creates a new client with default configuration" do
    assert {:ok, client} = TogglrSdk.new_client("test-api-key")
    assert is_pid(client.cache)
  end

  test "creates a new client with custom options" do
    opts = [
      base_url: "https://api.example.com",
      timeout: 60000,
      retries: 5,
      cache_enabled: true,
      cache_max_size: 2000,
      cache_ttl: 120
    ]

    assert {:ok, client} = TogglrSdk.new_client("test-api-key", opts)
    assert client.config.base_url == "https://api.example.com"
    assert client.config.timeout == 60000
    assert client.config.retries == 5
  end
end
