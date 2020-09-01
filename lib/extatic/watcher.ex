defmodule Extatic.Watcher do
  use GenServer

  alias Extatic.Compiler
  alias Extatic.{Compiler.Incremental, Compiler.Context}

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

    Compiler.Traverse.run()

    {:ok, %{}}
  end

  def handle_info({:file_event, _watcher_pid, {file, [_, :removed]}}, state) do
    Incremental.Registry.terminate_file_process(file)
    Context.Registry.terminate(file)

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {file, [:created]}}, state) do
    process_file(file)

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {file, [_, :modified, _]}}, state) do
    process_file(file)

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {_file, _events}}, state) do
    Compiler.Traverse.run()

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp process_file(file) do
    get_relative_input_path(file)
    |> compile_file()
  end

  defp compile_file("."), do: :ok

  defp compile_file(file) do
    Context.Registry.get_or_start(file)

    Incremental.Registry.get_or_create_file_process(file)
    |> Incremental.Node.compile()
    |> case do
      :ok ->
        :ok

      _ ->
        file |> Path.dirname() |> compile_file()
    end
  end
end
