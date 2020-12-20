defmodule Still.Compiler.ViewHelpers.ResponsiveImage do
  alias Still.Compiler.Incremental
  alias Still.Compiler.ViewHelpers.{ContentTag, UrlFor}
  alias Still.Preprocessor

  import Still.Utils

  require Logger

  @default_nr_of_sizes 4

  @spec render(file :: String.t(), list()) :: String.t()
  def render(file, opts \\ []) do
    {image_opts, opts} = Keyword.pop(opts, :image_opts, %{})

    output_files =
      file
      |> do_render(image_opts)
      |> get_output_files()

    ContentTag.render("img", nil, [
      {:src, render_src(output_files)},
      {:srcset, render_srcset(output_files)} | opts
    ])
  end

  defp do_render(file, image_opts) do
    Incremental.Registry.get_or_create_file_process(file)
    |> Incremental.Node.render(get_render_data(file, image_opts))
  end

  defp get_output_files(%{metadata: %{image_output_files: output_files}}) do
    output_files |> Enum.sort_by(&elem(&1, 0))
  end

  defp render_src(output_files) do
    {_, biggest_output_file} = output_files |> List.last()
    UrlFor.render(biggest_output_file)
  end

  defp render_srcset(output_files) do
    output_files
    |> Enum.map(fn {size, file} ->
      "#{UrlFor.render(file)} #{size}w"
    end)
    |> Enum.join(", ")
  end

  @spec get_render_data(String.t(), any()) :: %{
          image_opts: Preprocessor.ResponsiveImage.opts()
        }
  defp get_render_data(_, %{sizes: _} = image_opts) do
    %{image_opts: image_opts}
  end

  defp get_render_data(file, image_opts) do
    width =
      file
      |> get_input_path()
      |> get_image_info()
      |> Map.get("image_width")

    step_width = Integer.floor_div(width, @default_nr_of_sizes)

    image_opts =
      image_opts
      |> Map.put(
        :sizes,
        1..@default_nr_of_sizes
        |> Enum.map(&(&1 * step_width))
      )

    %{image_opts: image_opts}
  end
end
