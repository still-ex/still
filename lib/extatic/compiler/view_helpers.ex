defmodule Extatic.Compiler.ViewHelpers do
  @included_file_ext ".slime"

  import Extatic.Utils

  def include(file) do
    with {:ok, content} <-
           [
             get_input_path(),
             get_includes_directory(),
             file <> @included_file_ext
           ]
           |> Path.join()
           |> File.read!()
           |> Extatic.Compiler.Content.compile() do
      content
    else
      _ -> ""
    end
  end
end
