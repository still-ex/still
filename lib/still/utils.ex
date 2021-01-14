defmodule Still.Utils do
  alias Still.SourceFile

  def get_modified_time!(path) do
    path
    |> File.stat!()
    |> Map.get(:mtime)
    |> Timex.to_datetime()
  end

  def get_modified_time(path) do
    path
    |> File.stat()
    |> case do
      {:ok, stat} ->
        {:ok,
         stat
         |> Map.get(:mtime)
         |> Timex.to_datetime()}

      _ ->
        :error
    end
  end

  if Code.ensure_loaded?(Imageflow) do
    alias Imageflow.Native

    @spec get_image_info(file :: String.to_atom()) ::
            {:ok, %{width: integer(), height: integer()}} | {:error, any()}
    def get_image_info(file) do
      job = Native.create!()

      with :ok <- Native.add_input_file(job, 0, file),
           {:ok, %{"code" => 200, "data" => %{"image_info" => image_info}}} <-
             Native.message(job, "v0.1/get_image_info", %{io_id: 0}) do
        {:ok,
         %{
           width: image_info["image_width"],
           height: image_info["image_height"]
         }}
      end
    end
  else
    @spec get_image_info(file :: String.to_atom()) ::
            {:ok, %{width: integer(), height: integer()}} | {:error, any()}
    def get_image_info(file) do
      Mogrify.open(file)
      |> Mogrify.verbose()
      |> case do
        {:error, error} -> {:error, error}
        res -> {:ok, Map.take(res, [:height, :width])}
      end
    end
  end

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

  def mk_output_dir() do
    get_output_path()
    |> File.mkdir_p!()
  end

  def mk_output_dir(path) do
    get_output_path(path)
    |> File.mkdir_p!()
  end

  def clean_output_dir() do
    File.rm_rf(Path.join(get_output_path(), "*"))
  end

  def clean_output_dir(path) do
    File.rm_rf(Path.join(path, "*"))
  end

  def config!(key), do: Application.fetch_env!(:still, key)
  def config(key, default), do: Application.get_env(:still, key, default)
end
