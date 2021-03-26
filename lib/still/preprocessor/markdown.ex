defmodule Still.Preprocessor.Markdown do
  @moduledoc """
  Renders markdown files using
  [`Markdown`](https://github.com/still-ex/markdown).
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{content: content} = file) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)

    %{file | content: html_doc, extension: ".html"}
  end
end
