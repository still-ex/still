defmodule Extatic.Compiler.Context do
  use GenServer

  alias __MODULE__

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def put(file, var, value) do
    Context.Registry.get_or_start(file)
    |> GenServer.call({:put, var, value})
  end

  def get(file, var) do
    Context.Registry.get_or_start(file)
    |> GenServer.call({:get, var})
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, var, value}, _from, state) do
    state = Map.put(state, var, value)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, var}, _from, state) do
    {:reply, state[var], state}
  end
end
