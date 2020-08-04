defmodule Extatic.Compiler.ViewHelpers do
  import Extatic.Utils

  alias Extatic.{FileRegistry, FileProcess}

  def include(file) do
    with {:ok, pid} <- FileRegistry.get(file) do
      FileProcess.render(pid)
    else
      _ -> ""
    end
  end
end
