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

  def handle_info({:file_event, _watcher_pid, {file, _events}}, state) do
    get_relative_input_path(file)
    |> recompile()

    notify_subscribers(state.subscribers)

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp notify_subscribers(subscribers) do
    subscribers |> Enum.each(&send(&1, Application.fetch_env!(:extatic, :reload_msg)))
  end

  defp recompile("."), do: :ok

  defp recompile(file) do
    case FileRegistry.get(file) do
      {:error, :not_found} ->
        file |> Path.dirname() |> recompile()

      {:ok, pid} ->
        notify_file_process_subscribers(pid)
        FileProcess.compile(pid)
    end
  end

  defp notify_file_process_subscribers(pid) do
    FileRegistry.subscriptions()
    |> Enum.filter(fn {_k, pids} ->
      Enum.member?(pids, pid)
    end)
    |> Enum.map(fn {pid, _v} -> FileProcess.compile(pid) end)
  end
end
