defmodule Still.Preprocessor.Markdown do
  @moduledoc """
  Renders markdown files using
  [`Markdown`](https://github.com/still-ex/markdown).
  """

  alias Still.Preprocessor
  alias Still.Preprocessor.HtmlResponsiveImage

  use Preprocessor

  import Still.Utils

  @impl true
  def render(%{run_type: :compile_metadata} = source_file),
    do: %{source_file | extension: ".html"}

  def render(%{content: content} = source_file) do
    html_doc = Markdown.to_html(content, fenced_code: true, quote: true)
    source_file = %{source_file | content: html_doc, extension: ".html"}

    if use_responsive_images?() do
      Still.Preprocessor.HtmlResponsiveImage.render(source_file)
    else
      source_file
    end
  end

  defp use_responsive_images? do
    config!(__MODULE__)
    |> Keyword.get(:use_responsive_images, false)
  end
end
