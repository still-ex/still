defmodule Still.Image.Preprocessor.Mogrify do
  @moduledoc """
  Implements `Still.Image.Preprocessor.Adapter` for
  [Mogrify](https://github.com/route/mogrify).

  Default module used when no other adapter is provided.
  """
  use Still.Image.Preprocessor.Adapter

  alias Still.Image.Preprocessor.OutputFile

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
      |> get_output_files(output_file, opts)

    if file_changed?(input_file, output_files) do
      process_input_file(input_file, opts, output_files)
    end

    %{
      source_file
      | metadata: Map.put(metadata, :output_files, output_files)
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

  defp file_changed?(input_file, [%{file: output_file} | _]) do
    input_file_changed?(input_file, output_file)
  end

  defp get_output_files(sizes, output_file_path, opts) do
    extname = Path.extname(output_file_path)
    base_name = String.replace(output_file_path, extname, "")
    hash = :erlang.phash2(opts)

    Enum.map(sizes, fn size ->
      %OutputFile{
        width: size,
        file: "#{base_name}-#{hash}-#{size}w#{extname}"
      }
    end)
  end

  defp process_input_file(input_file, opts, output_files) do
    input_file_path = get_input_path(input_file)

    output_files
    |> Enum.map(fn %{width: size, file: output_file} ->
      Task.async(fn ->
        output_file_path = get_output_path(output_file)

        output_file_path |> Path.dirname() |> File.mkdir_p!()
        File.cp!(input_file_path, output_file_path)

        output_file_path
        |> open()
        |> apply_transformations(Map.get(opts, :transformations))
        |> resize(size)
        |> quality(config(:image_quality, 90))
        |> save(in_place: true)
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
