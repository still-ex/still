if Code.ensure_loaded?(Imageflow) do
  defmodule Still.Preprocessor.Image.Imageflow do
    use Still.Preprocessor

    alias Imageflow.Graph

    import Still.Utils

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
      graph =
        Graph.new()
        |> Graph.decode_file(get_input_path(input_file))
        |> apply_transformations(Map.get(opts, :transformations))

      output_files
      |> Enum.map(fn output_file ->
        Task.async(fn ->
          :ok =
            graph
            |> set_output(output_file)
            |> Graph.run()
        end)
      end)
      |> Enum.map(&Task.await(&1, :infinity))
    end

    defp set_output(graph, {size, file_name}) do
      file_path = file_name |> get_output_path()

      file_path |> Path.dirname() |> File.mkdir_p!()

      graph
      |> Graph.constrain(size, nil)
      |> Graph.encode_to_file(file_path)
    end

    defp apply_transformations(graph, [{function, args} | transformations]) do
      apply(Graph, function, [graph, args])
      |> apply_transformations(transformations)
    end

    defp apply_transformations(graph, _), do: graph
  end
end
