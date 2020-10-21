defmodule Still.Web.BrowserSubscriptions do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(pid) do
    GenServer.cast(__MODULE__, {:add, pid})
  end

  def notify do
    GenServer.cast(__MODULE__, :notify)
  end

  def init(_) do
    {:ok, %{subscribers: [], timer_ref: nil}}
  end

  def handle_cast({:add, pid}, state) do
    {:noreply, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_cast(:notify, state) do
    if not is_nil(state.timer_ref) do
      Process.cancel_timer(state.timer_ref)
    end

    timer_ref = Process.send_after(self(), :notify_subscribers, 800)

    {:noreply, %{state | timer_ref: timer_ref}}
  end

  def handle_info(:notify_subscribers, state) do
    state.subscribers
    |> Enum.each(&send(&1, Application.fetch_env!(:still, :reload_msg)))

    {:noreply, state}
  end
end
