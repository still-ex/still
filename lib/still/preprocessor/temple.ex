defmodule Still.Preprocessor.Temple do
  alias Still.{Preprocessor, SourceFile}

  use Preprocessor

  @impl true
  def render(%{content: content} = file) do
    {content, _} = Code.eval_string(content, [], __ENV__)
    %SourceFile{file | content: content, extension: ".html"}
  end
end
