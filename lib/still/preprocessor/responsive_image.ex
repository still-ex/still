defmodule Still.Preprocessor.ResponsiveImage do
  use Still.Preprocessor

  alias Imageflow.Graph

  @impl true
  def render(source_file) do
    input_file_path =
      source_file.input_file
      |> Still.Utils.get_input_path()

    output_file_path =
      source_file.output_file
      |> Still.Utils.get_output_path()

    Graph.new()
    |> Graph.decode_file(input_file_path)
    |> apply_transformations(Map.get(source_file.metadata, :image_transformations))
    |> Graph.encode_to_file(output_file_path)
    |> Graph.run()

    source_file
  end

  def apply_transformations(graph, [{function, args} | transformations]) do
    apply(Graph, function, [graph, args])
    |> apply_transformations(transformations)
  end

  def apply_transformations(graph, _), do: graph
end
