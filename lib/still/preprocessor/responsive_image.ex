defmodule Still.Preprocessor.ResponsiveImage do
  use Still.Preprocessor

  alias Imageflow.Graph

  import Still.Utils

  @type sizes :: list(integer())
  @type transformations :: list({atom(), any()})
  @type opts :: %{
          sizes: sizes(),
          transformations: transformations()
        }

  @impl true
  def render(
        %{
          metadata: %{responsive_image_opts: opts} = metadata,
          input_file: input_file,
          output_file: output_file
        } = source_file
      ) do
    output_files =
      opts
      |> Map.get(:sizes, [])
      |> get_output_files_with_sizes(output_file, opts)

    if input_changed?(input_file, output_files) do
      :ok =
        Graph.new()
        |> Graph.decode_file(get_input_path(input_file))
        |> apply_transformations(Map.get(opts, :transformations))
        |> branch_by_size(output_files)
        |> Graph.run()
    end

    %{
      source_file
      | metadata: Map.put(metadata, :responsive_image_output_files, output_files)
    }
  end

  @impl true
  def render(%{input_file: input_file, output_file: output_file} = source_file) do
    output_file
    |> Path.dirname()
    |> mk_output_dir()

    input_file
    |> get_input_path()
    |> File.cp!(get_output_path(output_file))

    source_file
  end

  defp input_changed?(input_file, [{_, output_file} | _]) do
    input_mtime =
      input_file
      |> get_input_path()
      |> File.stat!()
      |> Map.get(:mtime)
      |> Timex.to_datetime()

    output_file
    |> get_output_path()
    |> File.stat()
    |> case do
      {:ok, stat} ->
        output_mtime =
          stat
          |> Map.get(:mtime)
          |> Timex.to_datetime()

        Timex.compare(input_mtime, output_mtime) != -1

      _ ->
        true
    end
  end

  @spec branch_by_size(Graph.t(), sizes()) :: Graph.t()
  defp branch_by_size(graph, sizes) do
    sizes
    |> Enum.reduce(graph, fn {size, file_name}, graph ->
      graph
      |> Graph.branch(fn graph ->
        file_path = file_name |> get_output_path()

        file_path |> Path.dirname() |> File.mkdir_p!()

        graph
        |> Graph.constrain(size, nil)
        |> Graph.encode_to_file(file_path)
      end)
    end)
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

  @spec apply_transformations(Graph.t(), transformations()) :: Graph.t()
  defp apply_transformations(graph, [{function, args} | transformations]) do
    apply(Graph, function, [graph, args])
    |> apply_transformations(transformations)
  end

  defp apply_transformations(graph, _), do: graph
end
