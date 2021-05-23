defmodule Still.Preprocessor.Markdown do
  @moduledoc """
  Renders markdown files using
  [`Markdown`](https://github.com/still-ex/markdown).
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{run_type: :metadata} = source_file),
    do: %{source_file | extension: ".html"}

  def render(%{content: content} = source_file) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)

    %{source_file | content: html_doc, extension: ".html"}
  end
end
