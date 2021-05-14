defmodule Still.Compiler.Incremental.Node.Compile do
  @moduledoc """
  Compiles the contents of a `Still.Compiler.Incremental.Node`.

  First attempts a pass through copy of the file, in case it should be ignored.
  When this isn't successful, attempts a compilation via `Still.Compiler.File`,
  notifying any relevant subscribers of changes.
  """

  alias Still.Compiler

  alias Still.Compiler.PassThroughCopy

  def run(state) do
    case try_pass_through_copy(state) do
      :ok -> :ok
      _ -> do_compile(state)
    end
  end

  defp try_pass_through_copy(state) do
    PassThroughCopy.try(state.file)
  end

  defp do_compile(state) do
    cond do
      should_be_ignored?(state.file) ->
        :error

      true ->
        response = Compiler.File.compile(state.file)
        response
    end
  end

  defp should_be_ignored?(file) do
    Path.split(file) |> Enum.any?(&String.starts_with?(&1, "_"))
  end
end
