defmodule Extatic.FileProcess do
  use GenServer

  alias Extatic.{Compiler, FileRegistry}

  import Extatic.Utils

  def start_link(%{file: file}) do
    GenServer.start_link(__MODULE__, %{file: file}, name: file)
  end

  def compile(pid) do
    GenServer.call(pid, :compile)
  end

  def render(pid) do
    GenServer.call(pid, :render)
  end

  @impl true
  def init(%{file: file}) do
    {:ok, %{file: file |> to_string()}}
  end

  @impl true
  def handle_call(:compile, _from, state) do
    FileRegistry.clear_subscriptions()

    with :ok <- try_pass_through_copy(state) do
      {:reply, :ok, state}
    else
      _ -> do_compile(state)
    end
  end

  @impl true
  def handle_call(:render, _from, state) do
    FileRegistry.clear_subscriptions()

    {:reply, do_render(state), state}
  end

  defp try_pass_through_copy(state) do
    Compiler.PassThroughCopy.try(state.file)
  end

  defp do_compile(state) do
    if File.dir?(get_input_path(state.file)) do
      {:reply, :error, state}
    else
      Compiler.File.compile(state.file)
      {:reply, :ok, state}
    end
  end

  defp do_render(state) do
    Compiler.File.render(state.file)
  end
end
