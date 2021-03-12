defmodule Still.Preprocessor.PassThroughCopy do
  @moduledoc """
  """

  alias Still.Preprocessor

  use Preprocessor

  @impl true
  def render(%{input_file: input_file} = source_file, next_preprocessors) do
    input_file
    |> Still.Compiler.PassThroughCopy.try()
    |> case do
      :ok -> source_file
      _ -> next(source_file, next_preprocessors)
    end
  end
end
