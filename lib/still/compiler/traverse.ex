defmodule Still.Compiler.Traverse do
  @moduledoc """
  First step in the compilation stage. Traverses the input directory, adding any
  files or folders to `Still.Compiler.Incremental.Registry`.
  """

  import Still.Utils

  def run do
    Still.Compiler.Collections.reset()

    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()) do
      compilable_files()
      |> compile_files()
    end
  end

  def compilable_files(rel_path \\ "") do
    path = Path.join(get_input_path(), rel_path)

    cond do
      partial?(rel_path) ->
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

  def compile_files(files) do
    files
    |> Enum.map(fn file ->
      Task.async(fn ->
        dry_compile_file(file)
      end)
    end)
    |> Enum.each(fn task ->
      Task.await(task, :infinity)
    end)
  end

  defp partial?(path), do: String.starts_with?(path, "_")
end
