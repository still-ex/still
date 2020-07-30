defmodule Extatic.Compiler.ViewHelpers do
  import Extatic.Utils

  alias Extatic.Compiler

  def include(file) do
    with preprocessor <- Compiler.Preprocessor.for(file),
         {:ok, content} <-
           get_input_path()
           |> Path.join(file)
           |> File.read!()
           |> Compiler.Content.compile(preprocessor) do
      content
    else
      _ -> ""
    end
  end
end
