defmodule Still.Compiler.File do
  @moduledoc """
  Responsible for compiling or rendering a given file.

  The difference between compilation and renderisation is that the former
  outputs the source file's contents, after being processed, to the correct
  destination, while the latter only runs the content through the preprocessor
  pipeline.
  """
  require Logger

  alias Still.{SourceFile, Preprocessor}

  @doc """
  Compiles a given `Still.SourceFile` to the correct output path, after being
  run through its `Still.Preprocessor` pipeline.
  """
  def compile(input_file) do
    %SourceFile{input_file: input_file, run_type: :compile}
    |> Preprocessor.run()
    |> case do
      %SourceFile{} = file ->
        {:ok, file}

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end
  end

  @doc """
  Renders a given `Still.SourceFile`, using the correct metadata.

  This differs from compilation since it doesn't generate any output in the file
  system.
  """
  def render(input_file, metadata) do
    file = %SourceFile{input_file: input_file, metadata: metadata}

    with %SourceFile{} = file <- Preprocessor.run(file) do
      Logger.debug("Rendered #{input_file}")
      file
    else
      msg ->
        Logger.error("Failed to render #{input_file}")
        msg
    end
  end
end
