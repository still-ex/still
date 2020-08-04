defmodule Extatic.FileProcess do
  use GenServer

  alias Extatic.Compiler

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
    {:ok, %{file: file, subscribers: []}}
  end

  @impl true
  def handle_call(:compile, _from, state) do
    with :ok <- Compiler.PassThroughCopy.try(state.file |> to_string()) do
      :ok
    else
      _ -> do_compile(state.file)
    end

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:render, {from, _ref}, state) do
    {:reply, do_render(state.file),
     %{state | subscribers: [from | state.subscribers] |> Enum.uniq()}}
  end

  defp do_compile(file) do
    Compiler.File.compile(file |> to_string())
  end

  defp do_render(file) do
    Compiler.File.render(file |> to_string())
  end
end
