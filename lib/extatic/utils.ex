defmodule Extatic.Utils do
  def get_input_path() do
    Application.fetch_env!(:extatic, :input)
    |> Path.expand()
  end

  def get_output_path() do
    Application.fetch_env!(:extatic, :output)
    |> Path.expand()
  end
end
