defmodule Still.Compiler.File.Content do
  require Logger

  alias Still.SourceFile
  alias Still.Preprocessor

  @spec render(SourceFile.t()) :: SourceFile.t()
  def render(file) do
    Preprocessor.run(file)
  end

  @spec compile(SourceFile.t()) :: SourceFile.t()
  def compile(file) do
    render(%{file | run_type: :compile})
  end
end
