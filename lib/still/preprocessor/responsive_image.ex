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
  def render(%{metadata: %{responsive_image_opts: opts}} = source_file) do
    input_file_path =
      source_file.input_file
      |> Still.Utils.get_input_path()

    output_files =
      opts
      |> Map.get(:sizes, [])
      |> get_output_files_with_sizes(source_file.output_file)

    :ok =
      Graph.new()
      |> Graph.decode_file(input_file_path)
      |> apply_transformations(Map.get(opts, :transformations))
      |> branch_by_size(output_files)
      |> Graph.run()

    %{
      source_file
      | metadata: Map.put(source_file.metadata, :responsive_image_output_files, output_files)
    }
  end

  @impl true
  def render(%{input_file: input_file, output_file: output_file} = source_file) do
    output_file_path = get_output_path(output_file)

    output_file_path |> Path.dirname() |> File.mkdir_p!()

    input_file
    |> get_input_path()
    |> File.cp!(output_file_path)

    source_file
  end

  @spec branch_by_size(Graph.t(), sizes()) :: Graph.t()
  defp branch_by_size(graph, sizes) do
    sizes
    |> Enum.reduce(graph, fn {size, file_name}, graph ->
      graph
      |> Graph.branch(fn graph ->
        file_path = file_name |> Still.Utils.get_output_path()

        file_path |> Path.dirname() |> File.mkdir_p!()

        graph
        |> Graph.constrain(size, nil)
        |> Graph.encode_to_file(file_path)
      end)
    end)
  end

  defp get_output_files_with_sizes(sizes, output_file_path) do
    extname = Path.extname(output_file_path)
    base_name = String.replace(output_file_path, extname, "")

    sizes
    |> Enum.map(fn size ->
      {size, "#{base_name}-#{size}w#{extname}"}
    end)
  end

  @spec apply_transformations(Graph.t(), transformations()) :: Graph.t()
  defp apply_transformations(graph, [{function, args} | transformations]) do
    apply(Graph, function, [graph, args])
    |> apply_transformations(transformations)
  end

  defp apply_transformations(graph, _), do: graph
end
