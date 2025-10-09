defmodule TogglrSdk.ConfigTest do
  use ExUnit.Case
  doctest TogglrSdk.Config

  test "creates default configuration" do
    config = TogglrSdk.Config.default("test-api-key")
    assert config.api_key == "test-api-key"
    assert config.base_url == "https://localhost"
    assert config.timeout == 30_000
    assert config.retries == 3
    assert config.cache_enabled == true
    assert config.cache_max_size == 1000
    assert config.cache_ttl == 60
  end

  test "updates base URL" do
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_base_url("https://api.example.com")

    assert config.base_url == "https://api.example.com"
  end

  test "updates timeout" do
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_timeout(60000)

    assert config.timeout == 60000
  end

  test "updates retries" do
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_retries(5)

    assert config.retries == 5
  end

  test "updates backoff configuration" do
    backoff = TogglrSdk.BackoffConfig.new(0.5, 10.0, 1.5)
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_backoff(backoff)

    assert config.backoff_config == backoff
  end

  test "updates cache configuration" do
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_cache(true, 2000, 120)

    assert config.cache_enabled == true
    assert config.cache_max_size == 2000
    assert config.cache_ttl == 120
  end

  test "updates logger" do
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_logger(MyLogger)

    assert config.logger == MyLogger
  end

  test "chains multiple configuration updates" do
    backoff = TogglrSdk.BackoffConfig.new(0.2, 5.0, 1.8)
    config = TogglrSdk.Config.default("test-api-key")
    |> TogglrSdk.Config.with_base_url("https://api.example.com")
    |> TogglrSdk.Config.with_timeout(60000)
    |> TogglrSdk.Config.with_retries(5)
    |> TogglrSdk.Config.with_backoff(backoff)
    |> TogglrSdk.Config.with_cache(true, 2000, 120)
    |> TogglrSdk.Config.with_logger(MyLogger)

    assert config.api_key == "test-api-key"
    assert config.base_url == "https://api.example.com"
    assert config.timeout == 60000
    assert config.retries == 5
    assert config.backoff_config == backoff
    assert config.cache_enabled == true
    assert config.cache_max_size == 2000
    assert config.cache_ttl == 120
    assert config.logger == MyLogger
  end
end
