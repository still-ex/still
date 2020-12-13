defmodule Still.Compiler.File do
  require Logger

  alias Still.{SourceFile, Preprocessor}

  def compile(input_file) do
    file =
      %SourceFile{input_file: input_file, run_type: :compile}
      |> Preprocessor.run()

    {:ok, file}
  end

  def render(input_file, variables) do
    file = %SourceFile{input_file: input_file, variables: variables}

    with %SourceFile{} = file <- Preprocessor.run(file) do
      Logger.debug("Rendered #{input_file}")
      file
    else
      msg = {:error, :preprocessor_not_found} ->
        Logger.error("Preprocessor not found for #{input_file}")
        msg

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end
  end
end
