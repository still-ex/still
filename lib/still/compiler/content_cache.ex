defmodule Still.Compiler.ContentCache do
  @moduledoc """
  Used to store the contents read from files to avoid going to the disk until necessary.
  """
  @cache_name :content_cache

  @doc """
  Fetches the content of a file.
  """
  def get(file) do
    Cachex.get(@cache_name, file)
  end

  @doc """
  Saves the content of a file.
  """
  def set(file, content) do
    Cachex.put!(@cache_name, file, content)
  end

  @doc """
  Clears the content of a file.
  """
  def clear(file) do
    Cachex.del(@cache_name, file)
  end

  @doc """
  Clears the contents of every file.
  """
  def clear_all do
    Cachex.clear(@cache_name)
  end

  def cache_name, do: @cache_name
end
