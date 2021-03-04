defmodule Still.Compiler.TemplateHelpers.ContentTag do
  @moduledoc """
  Implements an arbitrary content tag with the given content.
  """

  @doc """
  Renders an arbitrary HTML tag with the given content.

  If `content` is `nil`, the rendered tag is self-closing.

  `opts` should contain the relevant HTML attributes (e.g `class: "myelem"`).

  `aria` attributes should be in the `aria_name` format (e.g: `aria_label: "Label"`).

  All data attributes should be within a `data` array (e.g: `data: [method:
  "POST", foo: "bar"]`).

  ## Examples

      iex> content_tag("a", "My link", href: "https://example.org", data: [method: "POST", something: "value"], aria_label: "Label")
      "<a href=\\"https://example.org\\" data-method=\\"POST\\" data-something=\\"value\\" aria-label=\\"Label\\">My link</a>"
  """
  def render(tag, content, opts) do
    {data, opts} = Keyword.pop(opts, :data, [])

    data_attrs = translate_data_attrs(data)
    basic_attrs = translate_basic_attrs(opts)

    attrs =
      basic_attrs
      |> Enum.concat(data_attrs)
      |> Enum.join(" ")

    opening_tag(tag, content, attrs) <> (content || "") <> closing_tag(tag, content)
  end

  defp opening_tag(tag, content, attrs) when is_nil(content) do
    "<#{tag} #{attrs}"
  end

  defp opening_tag(tag, _content, attrs) do
    "<#{tag} #{attrs}>"
  end

  defp closing_tag(_tag, content) when is_nil(content) do
    "/>"
  end

  defp closing_tag(tag, _content) do
    "</#{tag}>"
  end

  defp translate_basic_attrs(attrs) do
    Enum.map(attrs, fn {attr, value} -> ~s(#{translate_attr_name(attr)}="#{value}") end)
  end

  defp translate_data_attrs(data) do
    Enum.map(data, fn {attr, value} -> ~s(data-#{attr}="#{value}") end)
  end

  defp translate_attr_name(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> translate_attr_name()
  end

  defp translate_attr_name("aria_" <> name) do
    "aria-#{String.replace(name, "_", "-")}"
  end

  defp translate_attr_name(name) do
    name
  end
end
