defmodule Extatic.Compiler.ViewHelpers do
  import Extatic.Utils

  def include(file) do
    with {:ok, content} <-
           get_input_path()
           |> Path.join(file)
           |> File.read!()
           |> Extatic.Compiler.Content.compile() do
      content
    else
      _ -> ""
    end
  end
end
