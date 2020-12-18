defmodule Still.Web.ErrorFormatter do
  def format(e) do
    """
    <div class='dev-error'>
      <h1>#{e.source_file.input_file} #{e.message}</h1>
      #{render_stacktrace(e) |> String.trim()}
      <h2>Error</h2>
      <pre>
        <code>#{inspect(e, pretty: true) |> String.trim()}</code>
      </pre>
      </details>
    </div>
    """
    |> remove_whitespace()
  end

  defp render_stacktrace(%{stacktrace: nil}), do: ""

  defp render_stacktrace(e) do
    output =
      e.stacktrace
      |> Enum.map(&render_stacktrace_line/1)
      |> Enum.join("")

    """
      <h2>Stacktrace</h2>
      <pre>
        <code>
    #{output}
        </code>
      </pre>
    """
  end

  defp render_stacktrace_line({mod, fun, args, meta}) when is_list(args) do
    formatted_args =
      args
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")

    """
      <div class="dev-stack-item">
        <div><strong>#{mod}</strong>.#{fun}(#{formatted_args})</div>
        <div><em>#{Keyword.get(meta, :file)}:#{Keyword.get(meta, :line)}</em></div>
      </div>
    """
  end

  defp render_stacktrace_line({mod, fun, arity, meta}) when is_integer(arity) do
    """
      <div class="dev-stack-item">
        <div><strong>#{mod}</strong>.#{fun}/#{arity}</div>
        <div><em>#{Keyword.get(meta, :file)}:#{Keyword.get(meta, :line)}</em></div>
      </div>
    """
  end

  defp remove_whitespace(html) do
    html
    |> Floki.parse_fragment!()
    |> Floki.raw_html()
  end
end
