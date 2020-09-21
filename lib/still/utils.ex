defmodule Still.Utils do
  def get_input_path(file), do: Path.join(get_input_path(), file)

  def get_input_path() do
    Application.fetch_env!(:still, :input)
    |> Path.expand()
  end

  def get_output_path(file), do: Path.join(get_output_path(), file)

  def get_output_path() do
    Application.fetch_env!(:still, :output)
    |> Path.expand()
  end

  def get_relative_input_path(full_path) do
    full_path
    |> String.replace(Application.fetch_env!(:still, :input), "")
    |> String.trim_leading("/")
  end

  def rm_output_dir() do
    File.rm_rf(get_output_path())
  end

  def get_base_url() do
    Application.fetch_env!(:still, :base_url)
  end
end
