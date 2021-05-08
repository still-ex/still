defmodule Still.Preprocessor.Image.Mogrify do
  @moduledoc """
  Implements `Still.Preprocessor.Image.Adapter` for
  [Mogrify](https://github.com/route/mogrify).

  Default module used when no other adapter is provided.
  """
  use Still.Preprocessor.Image.Adapter

  import Still.Utils
  import Mogrify

  require ExImageInfo

  @impl true
  def render(
        %{
          metadata: %{image_opts: opts} = metadata,
          input_file: input_file,
          output_file: output_file
        } = source_file
      ) do
    output_files =
      opts
      |> Map.get(:sizes, [])
      |> get_output_files_with_sizes(output_file, opts)

    if input_file_changed?(input_file, output_files) do
      process_input_file(input_file, opts, output_files)
    end

    %{
      source_file
      | metadata: Map.put(metadata, :image_output_files, output_files)
    }
  end

  @impl true
  def get_image_info(file) do
    file
    |> File.read!()
    |> ExImageInfo.info()
    |> case do
      {_, width, height, _} -> {:ok, %{width: width, height: height}}
      _ -> {:error, "Failed to find image information for #{file}"}
    end
  end

  defp input_file_changed?(input_file, [{_, output_file} | _]) do
    input_mtime =
      input_file
      |> get_input_path()
      |> get_modified_time!()

    output_file
    |> get_output_path()
    |> get_modified_time()
    |> case do
      {:ok, output_mtime} ->
        Timex.compare(input_mtime, output_mtime) != -1

      _ ->
        true
    end
  end

  defp get_output_files_with_sizes(sizes, output_file_path, opts) do
    extname = Path.extname(output_file_path)
    base_name = String.replace(output_file_path, extname, "")
    hash = :erlang.phash2(opts)

    sizes
    |> Enum.map(fn size ->
      {size, "#{base_name}-#{hash}-#{size}w#{extname}"}
    end)
  end

  defp process_input_file(input_file, opts, output_files) do
    tmp_file =
      input_file
      |> get_input_path()
      |> open()
      |> apply_transformations(Map.get(opts, :transformations))

    output_files
    |> Enum.map(fn {size, output_file} ->
      Task.async(fn ->
        tmp_file
        |> resize(size)
        |> quality(config(:image_quality, 90))
        |> save(path: get_output_path(output_file))
      end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
  end

  defp apply_transformations(graph, [{function, args} | transformations]) do
    graph
    |> custom(function, args)
    |> apply_transformations(transformations)
  end

  defp apply_transformations(graph, _), do: graph
end
