defmodule Still.Utils.Map do
  def deep_atomify_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), deep_atomify_keys(v)}
      term -> term
    end)
  end

  def deep_atomify_keys(term), do: term
end
