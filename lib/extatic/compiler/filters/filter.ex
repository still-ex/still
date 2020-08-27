defmodule Extatic.Compiler.Filters.Filter do
  @callback apply(String.t(), keyword()) :: String.t() | no_return()
end
