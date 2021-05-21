defmodule Still.Web.BrowserSubscriptions do
  @moduledoc """
  Acts as a proxy between browser connections and file subscriptions. Whenever
  a relevant file changes, the browser connections are sent a reload message.
  Should only run in the `dev` environment.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Adds a new browser connection to the subscribers list.
  """
  def add(pid) do
    GenServer.cast(__MODULE__, {:add, pid})
  end

  @doc """
  Sends a reload message to the subscriptions.
  """
  def notify do
    GenServer.cast(__MODULE__, :notify)
  end

  @impl true
  def init(_) do
    {:ok, %{subscribers: [], timer_ref: nil}}
  end

  @impl true
  def handle_cast({:add, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  @impl true
  def handle_cast(:notify, state) do
    all_waiting()

    state.subscribers
    |> Enum.each(&send(&1, Jason.encode!(%{type: "reload"})))

    {:noreply, state}
  end

  defp all_waiting do
    receive do
      {:"$gen_cast", :notify} -> all_waiting()
    after
      100 -> :ok
    end
  end
end
