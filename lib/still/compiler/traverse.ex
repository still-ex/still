defmodule Still.Compiler.Traverse do
  @moduledoc """
  Traverses the input directory, compiling every file.
  """

  import Still.Utils

  @doc """
  Compiles every file in the input folder.
  """
  def run(callback \\ &compile_file/1) do
    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()) do
      compilable_files()
      |> compile_files(callback)
    end
  end

  defp compilable_files(rel_path \\ "") do
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

  defp compile_files(files, callback) do
    files
    |> Enum.map(fn file ->
      Task.async(fn ->
        callback.(file)
      end)
    end)
    |> Enum.each(fn task ->
      Task.await(task, :infinity)
    end)
  end

  defp partial?(path), do: String.starts_with?(path, "_")
end
