defmodule Still.Preprocessor.Markdown do
  alias Still.Preprocessor

  use Preprocessor, ext: ".html"

  def render(content, variables) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)

    %{content: html_doc, variables: variables}
  end
end
