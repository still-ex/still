defmodule Extatic.Watcher do
  use GenServer

  alias Extatic.{Compiler, FileRegistry, FileProcess}

  import Extatic.Utils

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(pid) do
    GenServer.cast(__MODULE__, {:subscribe, pid})
  end

  def init(_) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [get_input_path()])
    FileSystem.subscribe(watcher_pid)

    Compiler.compile()

    {:ok, %{subscribers: []}}
  end

  def handle_cast({:subscribe, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info({:file_event, _watcher_pid, {file, [:created]}}, state) do
    get_relative_input_path(file)
    |> compile()

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {file, [_, :removed]}}, state) do
    FileRegistry.terminate_file_process(file)
    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {file, [_, :modified, _]}}, state) do
    get_relative_input_path(file)
    |> compile()

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {_file, _events}}, state) do
    Compiler.compile()

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp compile("."), do: :ok

  defp compile(file) do
    FileRegistry.get_or_create_file_process(file)
    |> FileProcess.compile()
    |> case do
      :ok ->
        :ok

      _ ->
        file |> Path.dirname() |> compile()
    end
  end
end
