defmodule Still.Compiler.Collections do
  @moduledoc """
  Keeps track of all the collections within a compilation cycle.
  """

  use GenServer

  alias Still.Compiler.CompilationStage

  @impl true
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Resets the saved collections.
  """
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Returns the collection with a given name, subscribing caller's file to any
  future changes.
  """
  def get(collection, parent_file) do
    GenServer.call(__MODULE__, {:get, collection, parent_file})
  end

  @doc """
  Adds a file to its collections.
  """
  def add(file) do
    GenServer.call(__MODULE__, {:add, file |> Map.from_struct()})
  end

  @impl true
  def init(_) do
    {:ok, %{files: [], subscribers: %{}}}
  end

  @impl true
  def handle_call({:add, file}, _, state) do
    notify_subscribers(file, state)

    files = insert_file(file, state.files)

    {:reply, :ok, %{state | files: files}}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{files: [], subscribers: %{}}}
  end

  def handle_call({:get, collection, parent_file}, _from, state) do
    found = find_files(collection, state.files)

    subscribers = insert_subscriber(collection, parent_file, state.subscribers)

    {:reply, found, %{state | subscribers: subscribers}}
  end

  defp find_files(collection, files) do
    files
    |> Enum.filter(&Enum.member?(Map.get(&1[:metadata], :tag, []), collection))
  end

  defp insert_subscriber(collection, new_subscriber, subscribers) do
    collection_subscribers =
      Map.get(subscribers, collection, [])
      |> Enum.concat([new_subscriber])
      |> Enum.uniq()

    Map.put(subscribers, collection, collection_subscribers)
  end

  defp insert_file(file, files) do
    files
    |> Enum.filter(&(&1[:input_file] != file[:input_file]))
    |> Enum.concat([file])
  end

  defp notify_subscribers(file, state) do
    file
    |> Map.get(:metadata)
    |> Map.get(:tag, [])
    |> Enum.map(fn tag ->
      Map.get(state.subscribers, tag, [])
      |> CompilationStage.compile()
    end)
  end
end
