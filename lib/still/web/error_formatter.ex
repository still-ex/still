defmodule Still.Web.ErrorFormatter do
  @moduledoc """
  Prettifies compilation errors to be displayed in the browser.
  Should only run in the `dev` environment.
  """

  def format(e) do
    """
    <div class='dev-error'>
      <h1>#{error_title(e)}</h1>
      <h2>#{error_chain(e)}</h1>
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

  defp render_stacktrace(error) do
    output =
      error.stacktrace
      |> Exception.format_stacktrace()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.join("\n")
      |> String.trim()

    """
      <h2>Stacktrace</h2>
      <pre>
        <code>#{output}</code>
      </pre>
    """
  end

  defp remove_whitespace(html) do
    html
    |> Floki.parse_fragment!()
    |> Floki.raw_html()
  end

  defp error_chain(%{source_file: %{dependency_chain: dependency_chain}}) do
    dependency_chain
    |> Enum.reverse()
    |> Enum.join(" -> ")
  end

  defp error_title(%{
         payload: payload,
         stacktrace: stacktrace,
         kind: kind
       }) do
    Exception.normalize(kind, payload, stacktrace)
    |> Exception.message()
  end
end
