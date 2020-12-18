defmodule Still.Preprocessor.ResponsiveImage do
  use Still.Preprocessor

  alias Imageflow.Native
  alias Imageflow.Graph

  @impl true
  def render(source_file) do
    input_file_path =
      source_file.input_file
      |> Still.Utils.get_input_path()

    output_file_path = source_file.output_file

    sizes = get_sizes(input_file_path, output_file_path)

    Graph.new()
    |> Graph.decode_file(input_file_path)
    |> apply_transformations(Map.get(source_file.metadata, :image_transformations))
    |> branch_sizes(sizes)
    |> Graph.run()

    %{source_file | metadata: Map.put(source_file.metadata, :image_sizes, sizes)}
  end

  defp branch_sizes(graph, sizes) do
    sizes
    |> Enum.reduce(graph, fn {size, file_name}, graph ->
      graph
      |> Graph.branch(fn graph ->
        graph
        |> Graph.constrain(size, nil)
        |> Graph.encode_to_file(file_name)
      end)
    end)
  end

  defp get_sizes(input_file_path, output_file_path) do
    job = Native.create!()
    extname = Path.extname(output_file_path)
    base_name = String.replace(output_file_path, extname, "")

    with :ok <- Native.add_input_file(job, 0, input_file_path),
         {:ok, %{"code" => 200, "data" => %{"image_info" => %{"image_width" => width}}}} <-
           Native.message(job, "v0.1/get_image_info", %{io_id: 0}) do
      step_size = Integer.floor_div(width, 7)

      0..6
      |> Enum.reduce([], fn index, acc ->
        next = width - index * step_size

        if next > 200 do
          [{next, "#{base_name}-#{next}x#{extname}"} | acc]
        else
          acc
        end
      end)
    end
  end

  defp apply_transformations(graph, [{function, args} | transformations]) do
    apply(Graph, function, [graph, args])
    |> apply_transformations(transformations)
  end

  defp apply_transformations(graph, _), do: graph
end
