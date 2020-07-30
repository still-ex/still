defmodule Extatic.Watcher do
  use GenServer

  alias Extatic.Compiler

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

    compile()

    {:ok, %{subscribers: []}}
  end

  def handle_cast({:subscribe, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _events}}, state) do
    compile()
    notify_subscribers(state.subscribers)

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp notify_subscribers(subscribers) do
    subscribers |> Enum.each(&send(&1, Application.fetch_env!(:extatic, :reload_msg)))
  end

  defp compile() do
    Compiler.compile(get_input_path(), get_output_path())
  end
end
