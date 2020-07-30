defmodule Extatic.Utils do
  @default_include_dir "_includes"

  def get_input_path() do
    Application.fetch_env!(:extatic, :input)
    |> Path.expand()
  end

  def get_output_path() do
    Application.fetch_env!(:extatic, :output)
    |> Path.expand()
  end

  def get_includes_directory() do
    Application.get_env(:extatic, :include_dir, @default_include_dir)
  end
end
