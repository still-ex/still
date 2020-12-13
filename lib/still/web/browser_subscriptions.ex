defmodule Still.Web.BrowserSubscriptions do
  use GenServer

  alias Still.Compiler.CompilationStage

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(pid) do
    GenServer.cast(__MODULE__, {:add, pid})
  end

  def init(_) do
    Process.send_after(self(), :subscribe, 100)
    {:ok, %{subscribers: [], timer_ref: nil}}
  end

  def handle_cast({:add, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_info(:bus_empty, state) do
    state.subscribers
    |> Enum.each(&send(&1, Jason.encode!(%{type: "reload"})))

    {:noreply, state}
  end

  def handle_info(:subscribe, state) do
    CompilationStage.subscribe()
    {:noreply, state}
  end
end
