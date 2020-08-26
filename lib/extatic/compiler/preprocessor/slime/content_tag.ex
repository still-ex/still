if Code.ensure_loaded?(Slime) do
  defmodule Extatic.Compiler.Preprocessor.Slime.ContentTag do
    require Slime

    def render(tag, content, opts) do
      {data, opts} = Keyword.pop(opts, :data, [])

      data_attrs = translate_data_attrs(data)
      basic_attrs = translate_basic_attrs(opts)

      attrs =
        basic_attrs
        |> Enum.concat(data_attrs)
        |> Enum.join(" ")

      """
      #{tag} #{attrs}
        | #{content}
      """
    end

    defp translate_basic_attrs(attrs) do
      Enum.map(attrs, fn {attr, value} -> ~s(#{attr}="#{value}") end)
    end

    defp translate_data_attrs(data) do
      Enum.map(data, fn {attr, value} -> ~s(data-#{attr}="#{value}") end)
    end
  end
end
