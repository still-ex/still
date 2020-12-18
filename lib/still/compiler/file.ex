defmodule Still.Compiler.File do
  require Logger

  alias Still.{SourceFile, Preprocessor}

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
