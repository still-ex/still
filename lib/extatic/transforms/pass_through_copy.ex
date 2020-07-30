defmodule Extatic.Transforms.PassThroughCopy do
  import Extatic.Utils

  require Logger

  def run(folder) do
    with {:ok, _} <-
           File.cp_r(Path.join(get_input_path(), folder), Path.join(get_output_path(), folder)) do
      Logger.info("Pass through copy #{folder}")
      :ok
    else
      _ ->
        Logger.error("Failed to process #{folder} in #{__MODULE__}")
    end
  end
end
