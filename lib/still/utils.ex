defmodule Still.Utils do
  alias Still.SourceFile

  def get_input_path(%SourceFile{input_file: file}), do: Path.join(get_input_path(), file)

  def get_input_path(file), do: Path.join(get_input_path(), file)

  def get_input_path() do
    config!(:input)
    |> Path.expand()
  end

  def get_output_path(%SourceFile{output_file: file}), do: Path.join(get_output_path(), file)

  def get_output_path(file), do: Path.join(get_output_path(), file)

  def get_output_path() do
    config!(:output)
    |> Path.expand()
  end

  def get_relative_input_path(full_path) do
    full_path
    |> String.replace(config!(:input), "")
    |> String.trim_leading("/")
  end

  def get_base_url() do
    config!(:base_url)
  end

  def rm_output_dir() do
    get_output_path()
    |> File.rm_rf()
  end

  def config!(key), do: Application.fetch_env!(:still, key)
  def config(key, default), do: Application.get_env(:still, key, default)
end
