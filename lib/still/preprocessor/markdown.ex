defmodule Still.Preprocessor.Markdown do
  alias Still.Image.TemplateHelpers

  @moduledoc """
  Transforms markdown into HTML using [`Earmark`](https://github.com/pragdave/earmark).

  Set the property `:use_responsive_images` in your config to render responsive images:

  ```
  config :still, Still.Preprocessor.Markdown, use_responsive_images: true
  ```

  Images that have the attribute "#{TemplateHelpers.no_responsive_image()}" are ignored.
  """

  use Still.Preprocessor

  import Still.Utils

  @impl true
  def render(%{run_type: :compile_metadata} = source_file),
    do: %{source_file | extension: ".html"}

  def render(%{content: content, input_file: input_file} = source_file) do
    html_doc =
      Earmark.as_html!(
        content,
        compact_output: true,
        registered_processors:
          {"img",
           fn node ->
             if use_responsive_images?() && has_image?(node) && no_srcset?(node) && ignored?(node) do
               add_srcset(input_file, node)
             else
               node
             end
           end}
      )

    %{source_file | content: html_doc, extension: ".html"}
  end

  @dialyzer {:nowarn_function, use_responsive_images?: 0}
  defp use_responsive_images? do
    config(__MODULE__, [])
    |> Keyword.get(:use_responsive_images, false)
  end

  defp add_srcset(input_file, node) do
    output_files =
      input_file
      |> Path.dirname()
      |> Path.join(find_node_attr(node, "src"))
      |> Path.expand(get_input_path())
      |> get_relative_input_path()
      |> TemplateHelpers.get_output_files()

    node
    |> remove_att_in_node("src")
    |> Earmark.AstTools.merge_atts_in_node(
      src: TemplateHelpers.render_src(output_files),
      srcset: TemplateHelpers.render_srcset(output_files)
    )
  end

  defp find_node_attr(node, attr) do
    Earmark.AstTools.find_att_in_node(node, attr, nil)
  end

  defp ignored?(node) do
    find_node_attr(node, TemplateHelpers.no_responsive_image())
    |> is_nil()
  end

  defp no_srcset?(node) do
    find_node_attr(node, "srcset")
    |> is_nil()
  end

  defp has_image?(node) do
    Earmark.AstTools.find_att_in_node(node, "src", "")
    |> TemplateHelpers.is_img?()
  end

  defp remove_att_in_node({tag, atts, content, meta}, att) do
    atts = Enum.filter(atts, fn {tag, _} -> tag != att end)

    {tag, atts, content, meta}
  end
end
