defmodule Extatic.Compiler.Collections do
  use GenServer

  alias Extatic.Utils

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(collection, value) do
    GenServer.call(__MODULE__, {:add, collection, value})
  end

  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  def all() do
    GenServer.call(__MODULE__, {:all})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end

  def handle_call({:add, collection, value}, _from, state) do
    value = Utils.Map.deep_atomify_keys(value)

    values =
      Map.get(state, collection, [])
      |> Enum.reject(&(&1[:id] == value[:id]))

    state =
      state
      |> put_in([collection], [value] ++ values)

    {:reply, :ok, state}
  end

  def handle_call({:all}, _from, state) do
    {:reply, state, state}
  end
end
