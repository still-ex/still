defmodule Extatic.Compiler.ViewHelpers.Link do
  import Extatic.Utils

  alias Extatic.Compiler.ViewHelpers.ContentTag

  def render(opts, variables, do: markup) do
    preprocessor = variables[:preprocessor]
    %{content: content} = preprocessor.render(markup, variables |> Enum.into(%{}))
    render(content, variables, opts)
  end

  def render(text, _variables, opts) do
    {url, opts} = pop_url(opts)

    ContentTag.render("a", text, [{:href, url} | opts])
  end

  defp pop_url(opts) do
    {to, opts} = Keyword.pop!(opts, :to)

    case URI.parse(to) do
      %URI{host: nil, scheme: nil, path: path} when not is_nil(path) ->
        to = add_base_url(to)
        {to, opts}

      %URI{scheme: scheme} when scheme in ["http", "https"] ->
        opts = add_absolute_path_opts(opts)
        {to, opts}

      _ ->
        {to, opts}
    end
  end

  defp add_base_url("/" <> path), do: add_base_url(path)
  defp add_base_url(path), do: get_base_url() <> "/" <> path

  defp add_absolute_path_opts(opts) do
    opts
    |> Keyword.put_new(:target, "_blank")
    |> Keyword.put_new(:rel, "noopener noreferrer")
  end
end
