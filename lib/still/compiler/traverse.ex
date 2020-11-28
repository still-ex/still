defmodule Still.Compiler.Traverse do
  import Still.Utils

  alias Still.Compiler.{Incremental, CompilationQueue}

  def run() do
    Still.Compiler.Collections.reset()

    with true <- File.dir?(get_input_path()),
         _ <- File.rmdir(get_output_path()),
         :ok <- File.mkdir_p(get_output_path()) do
      do_run()
    end
  end

  def do_run(folder \\ "") do
    with {:ok, files} <- File.ls(Path.join(get_input_path(), folder)),
         files <- Enum.reject(files, &String.starts_with?(&1, "_")),
         _ <- Enum.map(files, &compile_file(Path.join(folder, &1))) do
      :ok
    end
  end

  defp compile_file(file) do
    if File.dir?(get_input_path(file)) do
      process_folder(file)
    else
      process_file(file)
    end
  end

  defp process_folder(folder) do
    folder
    |> Incremental.Registry.get_or_create_file_process()
    |> Incremental.Node.compile()
    |> case do
      {:ok, _} -> :ok
      _ -> do_run(folder)
    end
  end

  defp process_file(file) do
    file |> CompilationQueue.compile()
  end
end
