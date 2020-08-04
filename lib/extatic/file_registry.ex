defmodule Extatic.FileRegistry do
  use GenServer

  alias __MODULE__.Supervisor

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(file) do
    GenServer.call(__MODULE__, {:get, file})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:get, file}, _from, state) do
    {:reply, Supervisor.get_or_create_file_process(file |> String.to_atom()), state}
  end
end
