defmodule Still do
  @moduledoc false

  @doc """
  Registers a callback to be called synchronously after the compilation.
  """
  defdelegate after_compile(fun), to: Still.Compiler.Compile

  @doc """
  Compiles the site.
  """
  defdelegate compile(), to: Still.Compiler.Compile, as: :run
end
