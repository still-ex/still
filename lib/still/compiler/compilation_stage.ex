defmodule Still.Compiler.CompilationStage do
  @moduledoc """
  There are many events that lead to a file being compiled:

  * when Still starts, all files are compiled;
  * files that change are compiled;
  * files that include files that have changed are compiled;
  * any many more.

  Every compilation request goes through the `CompilationStage`. Subscribers
  to this process are notified when the queue is empty, which is usefull to
  refresh the browser or finish the compilation task in production.
  """
  use GenServer

  alias Still.Compiler.Incremental

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def compile(file) do
    GenServer.cast(__MODULE__, {:compile, file})
  end

  def subscribe do
    GenServer.call(__MODULE__, :subscribe)
  end

  def unsubscribe do
    GenServer.call(__MODULE__, :unsubscribe)
  end

  def init(_) do
    {:ok, %{to_compile: [], subscribers: [], changed: false, timer: nil}}
  end

  def handle_call(:subscribe, {from, _}, state) do
    [from | state.subscribers] |> Enum.uniq()

    {:reply, :ok, %{state | subscribers: [from | state.subscribers] |> Enum.uniq()}}
  end

  def handle_call(:unsubscribe, {from, _}, state) do
    [from | state.subscribers] |> Enum.uniq()

    {:reply, :ok, %{state | subscribers: state.subscribers |> Enum.reject(&(&1 == from))}}
  end

  def handle_cast({:compile, files}, state) when is_list(files) do
    if state.timer do
      Process.cancel_timer(state.timer)
    end

    {:noreply,
     %{
       state
       | to_compile: Enum.concat(files, state.to_compile),
         timer: Process.send_after(self(), :run, 100)
     }}
  end

  def handle_cast({:compile, file}, state) do
    if state.timer do
      Process.cancel_timer(state.timer)
    end

    {:noreply,
     %{
       state
       | to_compile: [file | state.to_compile],
         timer: Process.send_after(self(), :run, 100)
     }}
  end

  def handle_info(:run, %{to_compile: [], changed: true} = state) do
    state.subscribers
    |> Enum.each(fn pid ->
      send(pid, :bus_empty)
    end)

    {:noreply, %{state | changed: false, timer: nil}}
  end

  def handle_info(:run, %{to_compile: []} = state) do
    {:noreply, %{state | timer: nil}}
  end

  def handle_info(:run, state) do
    state.to_compile
    |> Enum.uniq()
    |> Enum.map(fn file ->
      Task.async(fn ->
        compile_file(file)
      end)
    end)
    |> Enum.map(fn task ->
      Task.await(task, Incremental.Node.compilation_timeout())
    end)

    Process.send_after(self(), :run, 900)

    {:noreply, %{state | to_compile: [], changed: true, timer: nil}}
  end

  defp compile_file("."), do: :ok

  defp compile_file("/"), do: :ok

  defp compile_file(file) do
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
