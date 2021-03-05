defmodule Still.Compiler.Incremental.Node.Compile do
  @moduledoc """
  Compiles the contents of a `Still.Compiler.Incremental.Node`.

  First attempts a pass through copy of the file, in case it should be ignored.
  When this isn't successful, attempts a compilation via `Still.Compiler.File`,
  notifying any relevant subscribers of changes.
  """

  alias Still.Compiler

  alias Still.Compiler.{
    CompilationStage,
    Incremental,
    PassThroughCopy
  }

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
        notify_subscribers(state)
        :error

      true ->
        remove_all_subscriptions(state)
        response = Compiler.File.compile(state.file)
        notify_subscribers(state)
        response
    end
  end

  defp remove_all_subscriptions(state) do
    state.subscriptions
    |> Enum.map(&Incremental.Registry.get_or_create_file_process/1)
    |> Enum.map(&Incremental.Node.remove_subscriber(&1, state.file))
  end

  defp notify_subscribers(state) do
    state.subscribers
    |> CompilationStage.compile()
  end

  defp should_be_ignored?(file) do
    Path.split(file) |> Enum.any?(&String.starts_with?(&1, "_"))
  end
end
