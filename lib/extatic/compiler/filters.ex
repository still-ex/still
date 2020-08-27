defmodule Extatic.Compiler.Filters do
  alias __MODULE__

  def cssmin(content, opts \\ []), do: Filters.CSSmin.apply(content, opts)

  def jsmin(content, opts \\ []), do: Filters.JSmin.apply(content, opts)
end
