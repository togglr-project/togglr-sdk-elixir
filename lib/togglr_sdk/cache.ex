defmodule TogglrSdk.Cache do
  @moduledoc """
  Cache module for Togglr SDK.

  Provides LRU caching with TTL using Cachex for storing feature evaluation results.
  """

  use GenServer
  require Logger

  @type cache_entry :: %{
          value: String.t(),
          enabled: boolean(),
          found: boolean(),
          timestamp: integer()
        }

  @type t :: %__MODULE__{
          cache_name: atom(),
          max_size: non_neg_integer(),
          ttl: non_neg_integer()
        }

  defstruct [:cache_name, :max_size, :ttl]

  @doc """
  Starts the cache process.

  ## Parameters

  - `max_size`: Maximum number of entries in the cache (default: 1000)
  - `ttl`: Time to live in seconds (default: 60)

  ## Examples

      iex> {:ok, pid} = TogglrSdk.Cache.start_link(1000, 60)
      iex> is_pid(pid)
      true

  """
  def start_link(max_size \\ 1000, ttl \\ 60) do
    cache_name = :togglr_sdk_cache
    GenServer.start_link(__MODULE__, {cache_name, max_size, ttl}, name: __MODULE__)
  end

  @doc """
  Gets a value from the cache.

  ## Examples

      iex> TogglrSdk.Cache.get("feature:key")
      nil
      iex> TogglrSdk.Cache.put("feature:key", %{value: "test", enabled: true, found: true})
      iex> TogglrSdk.Cache.get("feature:key")
      %{value: "test", enabled: true, found: true, timestamp: _}

  """
  def get(key) when is_binary(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Puts a value into the cache.

  ## Examples

      iex> entry = %{value: "test", enabled: true, found: true}
      iex> TogglrSdk.Cache.put("feature:key", entry)
      :ok

  """
  def put(key, entry) when is_binary(key) and is_map(entry) do
    GenServer.call(__MODULE__, {:put, key, entry})
  end

  @doc """
  Deletes a value from the cache.

  ## Examples

      iex> TogglrSdk.Cache.delete("feature:key")
      :ok

  """
  def delete(key) when is_binary(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  @doc """
  Clears all entries from the cache.

  ## Examples

      iex> TogglrSdk.Cache.clear()
      :ok

  """
  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  @doc """
  Gets cache statistics.

  ## Examples

      iex> TogglrSdk.Cache.stats()
      %{size: 0, hits: 0, misses: 0}

  """
  def stats do
    GenServer.call(__MODULE__, :stats)
  end

  # GenServer callbacks

  @impl true
  def init({cache_name, max_size, ttl}) do
    # Create the cache with Cachex
    case Cachex.start_link(cache_name, [limit: max_size, ttl: ttl * 1000]) do
      {:ok, _pid} ->
        state = %__MODULE__{
          cache_name: cache_name,
          max_size: max_size,
          ttl: ttl
        }
        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to start cache: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Cachex.get(state.cache_name, key) do
      {:ok, nil} ->
        {:reply, nil, state}

      {:ok, entry} ->
        # Add timestamp if not present
        entry_with_timestamp = Map.put_new(entry, :timestamp, System.system_time(:second))
        {:reply, entry_with_timestamp, state}

      {:error, reason} ->
        Logger.warning("Cache get error: #{inspect(reason)}")
        {:reply, nil, state}
    end
  end

  @impl true
  def handle_call({:put, key, entry}, _from, state) do
    entry_with_timestamp = Map.put(entry, :timestamp, System.system_time(:second))

    case Cachex.put(state.cache_name, key, entry_with_timestamp) do
      {:ok, true} ->
        {:reply, :ok, state}

      {:error, reason} ->
        Logger.warning("Cache put error: #{inspect(reason)}")
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    case Cachex.del(state.cache_name, key) do
      {:ok, true} ->
        {:reply, :ok, state}

      {:error, reason} ->
        Logger.warning("Cache delete error: #{inspect(reason)}")
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:clear, _from, state) do
    case Cachex.clear(state.cache_name) do
      {:ok, true} ->
        {:reply, :ok, state}

      {:error, reason} ->
        Logger.warning("Cache clear error: #{inspect(reason)}")
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:stats, _from, state) do
    case Cachex.stats(state.cache_name) do
      {:ok, stats} ->
        {:reply, stats, state}

      {:error, reason} ->
        Logger.warning("Cache stats error: #{inspect(reason)}")
        {:reply, %{size: 0, hits: 0, misses: 0}, state}
    end
  end
end
