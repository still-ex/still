defmodule Still.Compiler.ErrorCache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set(result) do
    GenServer.call(__MODULE__, {:set, result})
  end

  def get_errors() do
    GenServer.call(__MODULE__, :get_errors)
  end

  def init(_) do
    {:ok, %{errors: %{}}}
  end

  def handle_call(:get_errors, _, state) do
    {:reply, state.errors, state}
  end

  def handle_call({:set, {:ok, source_file}}, _, state) do
    errors = Map.put(state.errors, source_file.input_file, nil)
    state = %{state | errors: errors}

    {:reply, :ok, state}
  end

  def handle_call({:set, {:error, error}}, _, state) do
    errors = Map.put(state.errors, error.source_file.input_file, error)
    state = %{state | errors: errors}

    {:reply, :ok, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
