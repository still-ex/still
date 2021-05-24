defmodule Still.Compiler.Incremental.Node.Render do
  alias Still.SourceFile
  alias Still.Preprocessor
  alias Still.Compiler.{ErrorCache, PreprocessorError}

  def run(input_file, %{dependency_chain: dependency_chain} = data) do
    source_file =
      %SourceFile{
        input_file: input_file,
        dependency_chain: [input_file | dependency_chain],
        run_type: :render,
        metadata: Map.drop(data, [:dependency_chain])
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
