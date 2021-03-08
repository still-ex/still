defmodule Still.Compiler.CompilationStage do
  @moduledoc """
  Almost every compilation request goes through `CompilationStage`. This
  process is responsible for keeping track of files to compile and
  subscriptions (e.g: a browser subscribing to changes) and notifying all the
  subscribers of the end of the compilation cycle.

  Files are compiled in parallel. When no more files are ready to be compiled,
  the subscribers are notified.

  Subscribers to this process are notified when the queue is empty, which is
  usefull to refresh the browser or finish the compilation task in production.

  Subscribers receive the event `:bus_empty` when `CompilationStage`'s compilation
  cycle is finished.

  There are many events that lead to a file being compiled:

  * when Still starts, all files are compiled;
  * files that change are compiled;
  * files that include files that have changed are compiled;
  * any many more.
  """
  use GenServer

  alias Still.Compiler.Incremental.{Node, Registry}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Asynchronously pushes a file to the compilation list.
  """
  def compile(files) when is_list(files) do
    GenServer.cast(__MODULE__, {:compile, files})
  end

  def compile(file) do
    compile([file])
  end

  @doc """
  Save a subscription to the compilation cycle.
  """
  def subscribe do
    GenServer.call(__MODULE__, :subscribe)
  end

  @doc """
  Remove a subscription to the compilation cycle.
  """
  def unsubscribe do
    GenServer.call(__MODULE__, :unsubscribe)
  end

  @impl true
  def init(_) do
    {:ok, %{to_compile: [], subscribers: [], changed: false, timer: nil}}
  end

  @impl true
  def handle_call(:subscribe, {from, _}, state) do
    {:reply, :ok, %{state | subscribers: [from | state.subscribers] |> Enum.uniq()}}
  end

  def handle_call(:unsubscribe, {from, _}, state) do
    {:reply, :ok, %{state | subscribers: state.subscribers |> Enum.reject(&(&1 == from))}}
  end

  @impl true
  def handle_cast({:compile, files}, state) do
    for file <- files do
      file
      |> Registry.get_or_create_file_process()
      |> Node.changed()
    end

    if state.timer do
      Process.cancel_timer(state.timer)
    end

    {:noreply,
     %{
       state
       | to_compile: Enum.concat(files, state.to_compile) |> Enum.uniq(),
         timer: Process.send_after(self(), :run, 100)
     }}
  end

  @impl true
  def handle_info(:notify_subscribers, %{to_compile: []} = state) do
    state.subscribers
    |> Enum.each(fn pid ->
      send(pid, :bus_empty)
    end)

    {:noreply, state}
  end

  def handle_info(:notify_subscribers, state) do
    {:noreply, state}
  end

  def handle_info(:run, %{to_compile: [], changed: true} = state) do
    Process.send(self(), :notify_subscribers, [])

    {:noreply, %{state | changed: false, timer: nil}}
  end

  def handle_info(:run, %{to_compile: []} = state) do
    {:noreply, %{state | timer: nil}}
  end

  def handle_info(:run, state) do
    state.to_compile
    |> Enum.map(fn file ->
      Task.async(fn ->
        compile_file(file)
      end)
    end)
    |> Enum.each(fn task ->
      Task.await(task, Node.compilation_timeout())
    end)

    send(self(), :run)

    {:noreply, %{state | to_compile: [], changed: true, timer: nil}}
  end

  defp compile_file(file) do
    Registry.get_or_create_file_process(file)
    |> Node.compile()
  end
end
