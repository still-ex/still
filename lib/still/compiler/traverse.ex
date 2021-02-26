defmodule Still.Compiler.Traverse do
  @moduledoc """
  First step in the compilation stage. Traverses the input directory, adding any
  files or folders to `Still.Compiler.Incremental.Registry`.
  """

  import Still.Utils

  alias Still.Compiler.{Incremental, CompilationStage}

  def run() do
    Still.Compiler.Collections.reset()

    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()),
         files <- compilable_files() do
      files
      |> Enum.map(&compile_file/1)
    end
  end

  defp compile_file(file) do
    process_file(file)
  end

  defp process_file(file) do
    file |> CompilationStage.compile()
  end

  def compilable_files(rel_path \\ "") do
    path = Path.join(get_input_path, rel_path)

    cond do
      partial?(path) ->
        []

      File.regular?(path) ->
        [rel_path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&compilable_files(Path.join(rel_path, &1)))

      true ->
        []
    end
    |> List.flatten()
  end

  defp partial?(path), do: String.starts_with?(path, "_")
end
