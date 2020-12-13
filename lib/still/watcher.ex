defmodule Still.Watcher do
  use GenServer

  alias Still.Compiler
  alias Still.Compiler.{Incremental, CompilationStage}

  import Still.Utils

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(pid) do
    GenServer.cast(__MODULE__, {:subscribe, pid})
  end

  def init(_) do
    {:ok, %{}, {:continue, :async_compile}}
  end

  def handle_continue(:async_compile, state) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [get_input_path()])
    FileSystem.subscribe(watcher_pid)

    Compiler.Traverse.run()

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {file, events}}, state) do
    cond do
      Enum.member?(events, :modified) ->
        process_file(file)

      Enum.member?(events, :created) ->
        process_file(file)

      Enum.member?(events, :removed) ->
        Incremental.Registry.terminate_file_process(file)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp process_file(file) do
    get_relative_input_path(file)
    |> CompilationStage.compile()
  end
end
