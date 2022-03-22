defmodule Still.Preprocessor.Markdown do
  @moduledoc """
  Transforms markdown into HTML using [`Markdown`](https://github.com/still-ex/markdown).

  Set the property `:use_responsive_images` in your config to render responsive images:

  ```
  config :still, Still.Preprocessor.Markdown, use_responsive_images: true
  ```
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
      HtmlResponsiveImage.render(source_file)
    else
      source_file
    end
  end

  @dialyzer {:nowarn_function, use_responsive_images?: 0}
  defp use_responsive_images? do
    config(__MODULE__, [])
    |> Keyword.get(:use_responsive_images, false)
  end
end
