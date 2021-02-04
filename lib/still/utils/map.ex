defmodule Still.Utils.Map do
  @moduledoc """
  Collection of utility functions specific for extending the behaviour of map
  structures.
  """

  @doc """
  Converts all string keys of a map into atoms. Traverses the map to ensure
  that any subkeys are also converted.
  """
  def deep_atomify_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), deep_atomify_keys(v)}
      term -> term
    end)
  end

  def deep_atomify_keys(term), do: term
end
