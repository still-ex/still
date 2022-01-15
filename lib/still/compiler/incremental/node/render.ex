defmodule Still.Compiler.Incremental.Node.Render do
  @moduledoc """
  Renders a file.

  The difference between this module and
  #{Still.Compiler.Incremental.Node.Compile} is that during a render process we
  #never ignore a file or run it through a pass-through copy.
  """

  alias Still.Compiler.{ErrorCache, PreprocessorError}
  alias Still.Data
  alias Still.Preprocessor
  alias Still.SourceFile

  def run(input_file, %{dependency_chain: dependency_chain} = data) do
    source_file =
      %SourceFile{
        input_file: input_file,
        dependency_chain: [input_file | dependency_chain],
        run_type: :render,
        metadata: data |> Map.drop([:dependency_chain]) |> Map.put(:global, Data.global())
      }
      |> Preprocessor.run()

    ErrorCache.set({:ok, source_file})

    source_file
  catch
    _, %PreprocessorError{} = error ->
      raise error

    kind, payload ->
      error = %PreprocessorError{
        payload: payload,
        kind: kind,
        stacktrace: __STACKTRACE__,
        source_file: %Still.SourceFile{
          input_file: input_file,
          run_type: :render,
          dependency_chain: [input_file | dependency_chain]
        }
      }

      raise error
  end
end
