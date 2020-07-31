defmodule Extatic.Utils do
  def get_input_path(file), do: Path.join(get_input_path(), file)

  def get_input_path() do
    Application.fetch_env!(:extatic, :input)
    |> Path.expand()
  end

  def get_output_path(file), do: Path.join(get_output_path(), file)

  def get_output_path() do
    Application.fetch_env!(:extatic, :output)
    |> Path.expand()
  end

  def clean_output_dir() do
    File.rm_rf(get_output_path())
  end
end
