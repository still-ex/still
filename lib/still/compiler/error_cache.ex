defmodule Still.Compiler.ErrorCache do
  @moduledoc """
  Saves an error occurring within a file's compilation and allows them to be
  retrieved for a prettified display.

  Since files are compiled asynchronously, the browser (or other interested
  parties) require a centralised access to compilation errors.
  """
  use GenServer

  @impl true
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Save the given error or clear it if the compilation was successful.

  If `result` is `{:ok, source_file}`, the error cache for the given file is
  cleared. Otherwise it is updated.
  """
  def set(result) do
    GenServer.call(__MODULE__, {:set, result})
  end

  @doc """
  Retrieve all saved errors, for all files.
  """
  def get_errors() do
    GenServer.call(__MODULE__, :get_errors)
  end

  @impl true
  def init(_) do
    {:ok, %{errors: %{}}}
  end

  @impl true
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

  @impl true
  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end
end
