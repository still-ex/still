defmodule Extatic.FileRegistry do
  use GenServer

  alias __MODULE__.Supervisor

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(file) do
    GenServer.call(__MODULE__, {:get, file})
  end

  def get_or_create(file) do
    GenServer.call(__MODULE__, {:get_or_create, file})
  end

  def get_and_subscribe(file) do
    GenServer.call(__MODULE__, {:get_and_subscribe, file})
  end

  def clear_subscriptions do
    GenServer.call(__MODULE__, :clear_subscriptions)
  end

  def subscriptions do
    GenServer.call(__MODULE__, :subsriptions)
  end

  @impl true
  def init(_) do
    {:ok, %{subsriptions: %{}}}
  end

  @impl true
  def handle_call(:subsriptions, _from, state) do
    {:reply, state.subsriptions, state}
  end

  @impl true
  def handle_call(:clear_subscriptions, {pid, _ref}, state) do
    {:reply, :ok, put_in(state, [:subsriptions, pid], [])}
  end

  @impl true
  def handle_call({:get_and_subscribe, file}, {pid, _ref}, state) do
    {:ok, file_pid} = get_or_create_file_process(file)
    new_subscriptions = [file_pid | Map.get(state.subsriptions, pid, [])]
    {:reply, {:ok, file_pid}, put_in(state, [:subsriptions, pid], new_subscriptions)}
  end

  @impl true
  def handle_call({:get_or_create, file}, _from, state) do
    {:reply, get_or_create_file_process(file), state}
  end

  @impl true
  def handle_call({:get, file}, _from, state) do
    {:reply, get_file_process(file), state}
  end

  defp get_file_process(file) do
    Supervisor.get_file_process(file |> String.to_atom())
  end

  defp get_or_create_file_process(file) do
    Supervisor.get_or_create_file_process(file |> String.to_atom())
  end
end
