defmodule Still.Image.Preprocessor.Mogrify do
  @moduledoc """
  Implements `Still.Image.Preprocessor.Adapter` for
  [Mogrify](https://github.com/route/mogrify).

  Default module used when no other adapter is provided.
  """
  use Still.Image.Preprocessor.Adapter

  alias Still.SourceFile

  import Still.Utils
  import Mogrify

  require ExImageInfo

  @impl true
  def render(source_file) do
    output_source_files = get_output_source_files(source_file)

    if file_changed?(source_file, output_source_files) do
      process_input_file(source_file, output_source_files)
    end

    output_source_files
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

  defp file_changed?(%{input_file: input_file}, [%{output_file: output_file} | _]) do
    input_file_changed?(input_file, output_file)
  end

  defp get_output_source_files(%{
         metadata: %{image_opts: opts} = metadata,
         input_file: input_file,
         output_file: output_file
       }) do
    extname = Path.extname(output_file)
    base_name = String.replace(output_file, extname, "")
    hash = :erlang.phash2(opts)

    Map.get(opts, :sizes, [])
    |> Enum.map(fn size ->
      %SourceFile{
        input_file: input_file,
        output_file: "#{base_name}-#{hash}-#{size}w#{extname}",
        metadata: Map.put(metadata, :width, size)
      }
    end)
  end

  defp process_input_file(
         %{input_file: input_file, metadata: %{image_opts: opts}},
         output_source_files
       ) do
    input_file_path = get_input_path(input_file)

    output_source_files
    |> Enum.map(fn %{metadata: %{width: size}, output_file: output_file} ->
      Task.async(fn ->
        output_file_path = get_output_path(output_file)

        output_file_path |> Path.dirname() |> File.mkdir_p!()

        input_file_path
        |> open()
        |> apply_transformations(Map.get(opts, :transformations))
        |> resize(size)
        |> quality(config(:image_quality, 90))
        |> save(path: output_file_path)
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
