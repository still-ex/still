defmodule Still.Web.BrowserSubscriptions do
  @moduledoc """
  Acts as a proxy between browser connections and file subscriptions. Whenever
  a relevant file changes, the browser connections are sent a reload message.
  Should only run in the `dev` environment.
  """

  use GenServer

  alias Still.Compiler.CompilationStage

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Adds a new browser connection to the subscribers list.
  """
  def add(pid) do
    GenServer.cast(__MODULE__, {:add, pid})
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :subscribe, 100)
    {:ok, %{subscribers: [], timer_ref: nil}}
  end

  @impl true
  def handle_cast({:add, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  @impl true
  def handle_info(:bus_empty, state) do
    state.subscribers
    |> Enum.each(&send(&1, Jason.encode!(%{type: "reload"})))

    {:noreply, state}
  end

  @impl true
  def handle_info(:subscribe, state) do
    CompilationStage.subscribe()
    {:noreply, state}
  end
end
