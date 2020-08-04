defmodule Extatic.FileRegistry.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_or_create_file_process(file) do
    case Process.whereis(file) do
      nil ->
        DynamicSupervisor.start_child(__MODULE__, {Extatic.FileProcess, %{file: file}})

      pid ->
        {:ok, pid}
    end
  end
end
