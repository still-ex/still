defmodule Still.Compiler.ViewHelpers.Link do
  import Still.Utils

  alias Still.Compiler.ViewHelpers.ContentTag
  alias Still.SourceFile

  def render(opts, metadata, do: markup) do
    preprocessor = metadata[:preprocessor]

    %{content: content} =
      preprocessor.render(%SourceFile{
        content: markup,
        input_file: metadata[:input_file],
        metadata: metadata |> Enum.into(%{})
      })

    render(content, metadata, opts)
  end

  def render(text, _metadata, opts) do
    {url, opts} = pop_url(opts)

    ContentTag.render("a", text, [{:href, url} | opts])
  end

  defp pop_url(opts) do
    {to, opts} = Keyword.pop!(opts, :to)

    case URI.parse(to) do
      %URI{host: nil, scheme: nil, path: path} when not is_nil(path) ->
        to = to |> add_base_url() |> modernize()
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

  defp modernize(path) do
    path |> String.replace_suffix("index.html", "")
  end
end
