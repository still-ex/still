defmodule Extatic.Compiler.ViewHelpers.Link do
  import Extatic.Utils

  alias Extatic.Compiler

  def render(opts, do: markup) do
    render(markup, opts)
  end

  def render(text, opts) do
    {url, opts} = pop_url(opts)

    %{preprocessor: preprocessor} = Compiler.Context.current()

    preprocessor.content_tag("a", text, [{:href, url} | opts])
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
