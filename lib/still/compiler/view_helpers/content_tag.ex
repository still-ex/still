defmodule Still.Compiler.ViewHelpers.ContentTag do
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

  def opening_tag(tag, content, attrs) when is_nil(content) do
    "<#{tag} #{attrs}"
  end

  def opening_tag(tag, _content, attrs) do
    "<#{tag} #{attrs}>"
  end

  def closing_tag(_tag, content) when is_nil(content) do
    "/>"
  end

  def closing_tag(tag, _content) do
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
