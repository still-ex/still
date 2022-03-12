defmodule Still.Image.Preprocessor.Html do
  alias Still.Image.TemplateHelpers
  alias Still.{Preprocessor, SourceFile}

  @moduledoc """
  Parses an HTML `Still.SourceFile` and replaces HTML img with responsive images.
  Images that have the attributes "srcset" or "#{TemplateHelpers.no_responsive_image()}" are ignored.
  """

  use Preprocessor

  import Still.Utils

  def render(
        %SourceFile{
          extension: ".html",
          content: content,
          input_file: input_file
        } = source_file
      ) do
    {:ok, document} = Floki.parse_document(content)

    new_content =
      Floki.find_and_update(document, "img", fn
        {"img", attrs} ->
          if has_image?(attrs) && no_srcset?(attrs) && ignored?(attrs) do
            add_srcset(input_file, attrs)
          else
            {"img", remove_node_attr(attrs, TemplateHelpers.no_responsive_image())}
          end

        other ->
          other
      end)
      |> Floki.raw_html()

    %{source_file | content: new_content}
  end

  def render(source_file), do: source_file

  defp add_srcset(input_file, img_node_attrs) do
    output_files =
      input_file
      |> Path.dirname()
      |> Path.join(find_node_attr(img_node_attrs, "src"))
      |> Path.expand(get_input_path())
      |> get_relative_input_path()
      |> TemplateHelpers.get_output_files()

    {"img",
     img_node_attrs
     |> Enum.filter(fn {tag, _} -> tag != "src" end)
     |> Enum.concat([
       {"src", TemplateHelpers.render_src(output_files)},
       {"srcset", TemplateHelpers.render_srcset(output_files)}
     ])}
  end

  defp remove_node_attr(all_attrs, attr) do
    all_attrs
    |> Enum.reject(fn {key, _} -> key == attr end)
  end

  defp find_node_attr(all_attrs, attr) do
    all_attrs
    |> Enum.find(fn {key, _} -> key == attr end)
    |> case do
      {_, val} -> val
      _ -> nil
    end
  end

  defp ignored?(img_attrs) do
    find_node_attr(img_attrs, TemplateHelpers.no_responsive_image())
    |> is_nil()
  end

  defp no_srcset?(img_attrs) do
    find_node_attr(img_attrs, "srcset")
    |> is_nil()
  end

  defp has_image?(img_attrs) do
    find_node_attr(img_attrs, "src")
    |> TemplateHelpers.is_img?()
  end
end
