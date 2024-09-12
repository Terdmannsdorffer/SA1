defmodule Goodreads.Cache do
  @redix :redix

  require Logger

  def test_connection do
    case Redix.command(@redix, ["PING"]) do
      {:ok, "PONG"} ->
        Logger.info("Redis connection successful")
      {:error, reason} ->
        Logger.error("Redis connection failed: #{inspect(reason)}")
    end
  end

  def get(key) do
    Logger.info("Fetching key #{key} from Redis")
    case Redix.command(@redix, ["GET", key]) do
      {:ok, nil} ->
        Logger.info("Key #{key} not found in Redis")
        nil

      {:ok, value} ->
        Logger.info("Key #{key} found in Redis with value: #{value}")
        value

      {:error, reason} ->
        Logger.error("Error fetching key #{key} from Redis: #{inspect(reason)}")
        nil
    end
  end

  def set(key, value) do
    Logger.info("Setting key #{key} in Redis with value: #{value}")
    Redix.command(@redix, ["SET", key, value])
  end

  def set_with_ttl(key, value, ttl \\ 3600) do
    Logger.info("Setting key #{key} in Redis with value: #{value} and TTL: #{ttl}")
    Redix.command(@redix, ["SETEX", key, ttl, value])
  end

  def delete(key) do
    Logger.info("Deleting key #{key} from Redis")
    Redix.command(@redix, ["DEL", key])
  end
end
