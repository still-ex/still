defmodule Still.Preprocessor.Markdown do
  alias Still.Preprocessor

  use Preprocessor, ext: ".html"

  def render(%{content: content} = file) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)

    %{file | content: html_doc}
  end
end
