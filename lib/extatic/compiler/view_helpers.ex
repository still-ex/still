defmodule Extatic.Compiler.ViewHelpers do
  alias Extatic.{FileRegistry, FileProcess}

  def include(file) do
    with {:ok, pid} <- FileRegistry.get_and_subscribe(file) do
      FileProcess.render(pid)
    else
      _ -> ""
    end
  end
end
