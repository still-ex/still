defmodule Still.Compiler.Incremental.Node.Compile do
  @moduledoc """
  Compiles a file.

  At first, attempts a pass-through copy. If it doesn't apply, and the file
  should not be ignored, it is run through its preprocessor chain.

  This module is used both to compile and to compile the metadata. The
  difference between the two is the `:run_type` set in the #{Still.SourceFile}.
  Each preprocessor will then adapt accordingly.
  """

  alias Still.Compiler.{
    ErrorCache,
    Incremental.OutputToInputFileRegistry,
    PassThroughCopy,
    PreprocessorError
  }

  alias Still.Preprocessor
  alias Still.SourceFile

  require Logger

  def run(input_file, run_type \\ :compile) do
    source_file =
      %SourceFile{
        input_file: input_file,
        dependency_chain: [input_file],
        run_type: run_type
      }
      |> do_run()

    ErrorCache.set({:ok, source_file})

    if source_file.output_file do
      OutputToInputFileRegistry.register(input_file, source_file.output_file)
    end

    source_file
  catch
    _, %PreprocessorError{} = error ->
      handle_error(error)
      raise error

    kind, payload ->
      error = %PreprocessorError{
        payload: payload,
        kind: kind,
        stacktrace: __STACKTRACE__,
        source_file: %SourceFile{input_file: input_file, run_type: :compile}
      }

      handle_error(error)
      raise error
  end

  def do_run(source_file) do
    case try_pass_through_copy(source_file) do
      :ok -> %{source_file | output_file: source_file.input_file}
      _ -> do_compile(source_file)
    end
  end

  defp try_pass_through_copy(source_file) do
    PassThroughCopy.try(source_file.input_file)
  end

  defp do_compile(source_file) do
    cond do
      should_be_ignored?(source_file.input_file) ->
        source_file

      true ->
        Preprocessor.run(source_file)
    end
  end

  defp should_be_ignored?(file) do
    Path.split(file) |> Enum.any?(&String.starts_with?(&1, "_"))
  end

  defp handle_error(error) do
    Logger.error(error)

    if Still.Utils.compilation_task?() do
      System.stop(1)
    else
      ErrorCache.set({:error, error})
    end
  end
end
