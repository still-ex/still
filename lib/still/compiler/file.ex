defmodule Still.Compiler.File do
  @moduledoc """
  Responsible for compiling or rendering a given file.

  The difference between compilation and renderisation is that the former
  outputs the source file's contents, after being processed, to the correct
  destination, while the latter only runs the content through the preprocessor
  pipeline.
  """
  require Logger

  alias Still.{Preprocessor, SourceFile}

  @doc """
  Compiles a given `Still.SourceFile` to the correct output path, after being
  run through its `Still.Preprocessor` pipeline.
  """
  def compile(input_file) do
    source_file = %SourceFile{
      input_file: input_file,
      dependency_chain: [input_file],
      run_type: :compile
    }

    case Preprocessor.run(source_file) do
      %SourceFile{} = file ->
        {:ok, file}

      error ->
        Logger.error("Failed to compile #{input_file}")
        error
    end
  end

  @doc """
  Renders a given `Still.SourceFile`, using the correct metadata.

  This differs from compilation since it doesn't generate any output in the file
  system.
  """
  def render(%{input_file: input_file} = source_file) do
    case Preprocessor.run(source_file) do
      %SourceFile{} = source_file ->
        Logger.debug("Rendered #{input_file}")
        source_file

      error ->
        Logger.error("Failed to render #{input_file}")
        error
    end
  end
end
