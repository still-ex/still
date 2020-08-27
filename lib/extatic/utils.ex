defmodule Extatic.Utils do
  def get_input_path(file),
    do: Path.join(get_input_path(), file)

  def get_input_path,
    do: config!(:input) |> Path.expand()

  def get_output_path(file),
    do: Path.join(get_output_path(), file)

  def get_output_path,
    do: config!(:output) |> Path.expand()

  def get_javascripts_path,
    do: config!(:javascripts) |> Path.expand()

  def get_base_url, do: config!(:base_url)

  def get_relative_input_path(full_path) do
    full_path
    |> String.replace(config!(:input), "")
    |> String.trim_leading("/")
  end

  def rm_output_dir,
    do: get_output_path() |> File.rm_rf()

  defp config!(key), do: Application.fetch_env!(:extatic, key)
end
