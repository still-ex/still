defmodule Still.Compiler.Collections do
  @moduledoc """
  Keeps track of collections.
  """

  alias Still.SourceFile

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Resets the collections.
  """
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Returns the collection with a given name, subscribing caller's file to any
  future changes.
  """
  def get(collection) do
    GenServer.call(__MODULE__, {:get, collection}, :infinity)
  end

  @doc """
  Adds a file to its collections.
  """
  @spec add(SourceFile.t()) :: any()
  def add(file = %{metadata: %{tag: tag}}) when not is_nil(tag) do
    GenServer.call(__MODULE__, {:add, file}, :infinity)
  end

  def add(_file), do: :ok

  @impl true
  def init(_) do
    {:ok, %{files: []}}
  end

  @impl true
  def handle_call({:add, file}, _, state) do
    files = insert_file(file, state.files)

    {:reply, :ok, %{state | files: files}}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{files: []}}
  end

  def handle_call({:get, collection}, _from, state) do
    found = find_files(collection, state.files)

    {:reply, found, state}
  end

  defp find_files(collection, files) do
    files
    |> Enum.filter(&Enum.member?(Map.get(&1[:metadata], :tag, []), collection))
  end

  defp insert_file(file, files) do
    file =
      file
      |> Map.delete(:content)
      |> Map.from_struct()

    files
    |> Enum.filter(&(&1[:input_file] != file[:input_file]))
    |> Enum.concat([file])
  end
end
