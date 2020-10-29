defmodule Still.Preprocessor.Markdown do
  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def extension(_), do: ".html"

  @impl true
  def render(%{content: content} = file) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)

    %{file | content: html_doc}
  end
end
