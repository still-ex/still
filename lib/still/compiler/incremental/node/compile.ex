defmodule Still.Compiler.Incremental.Node.Compile do
  @moduledoc """
  Compiles the contents of a `Still.Compiler.Incremental.Node`.

  First attempts a pass through copy of the file, in case it should be ignored.
  When this isn't successful, attempts a compilation via `Still.Compiler.File`,
  notifying any relevant subscribers of changes.
  """

  alias Still.Preprocessor
  alias Still.Compiler.PassThroughCopy

  def run(source_file) do
    case try_pass_through_copy(source_file) do
      :ok -> :ok
      _ -> do_compile(source_file)
    end
  end

  defp try_pass_through_copy(source_file) do
    PassThroughCopy.try(source_file.input_file)
  end

  defp do_compile(source_file) do
    cond do
      should_be_ignored?(source_file.input_file) ->
        :error

      true ->
        Preprocessor.run(source_file)
    end
  end

  defp should_be_ignored?(file) do
    Path.split(file) |> Enum.any?(&String.starts_with?(&1, "_"))
  end
end
