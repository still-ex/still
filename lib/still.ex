defmodule Still do
  @moduledoc false

  defdelegate on_compile(fun), to: Still.Compiler.Compile
  defdelegate compile(), to: Still.Compiler.Compile, as: :run
end
