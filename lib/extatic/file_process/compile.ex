defmodule Extatic.FileProcess.Compile do
  import Extatic.Utils

  alias Extatic.{Compiler, FileRegistry, FileProcess}

  def run(state) do
    with :ok <- try_pass_through_copy(state) do
      :ok
    else
      _ -> do_compile(state)
    end
  end

  defp try_pass_through_copy(state) do
    Compiler.PassThroughCopy.try(state.file)
  end

  defp do_compile(state) do
    cond do
      File.dir?(get_input_path(state.file)) ->
        :error

      should_be_ignored?(state.file) ->
        notify_subscribers(state)
        :error

      true ->
        remove_all_subscriptions(state)
        Compiler.File.compile(state.file)
        notify_subscribers(state)
        :ok
    end
  end

  defp remove_all_subscriptions(state) do
    state.subscriptions
    |> Enum.map(&FileRegistry.get_or_create_file_process/1)
    |> Enum.map(&FileProcess.remove_subscriber(&1, state.file))
  end

  defp notify_subscribers(state) do
    state.subscribers
    |> Enum.map(&FileRegistry.get_or_create_file_process/1)
    |> Enum.map(&FileProcess.async_compile/1)
  end

  defp should_be_ignored?(file) do
    Path.split(file) |> Enum.any?(&String.starts_with?(&1, "_"))
  end
end
