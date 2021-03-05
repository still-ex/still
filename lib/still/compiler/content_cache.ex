defmodule Still.Compiler.ContentCache do
  @cache_name :content_cache

  def get(key) do
    Cachex.get(@cache_name, key)
  end

  def set(key, value) do
    Cachex.put!(@cache_name, key, value)
  end

  def clear(key) do
    Cachex.del(@cache_name, key)
  end

  def clear_all do
    Cachex.clear(@cache_name)
  end

  def cache_name, do: @cache_name
end
