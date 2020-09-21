defmodule Still.Compiler.Incremental.Registry do
  use DynamicSupervisor

  alias Still.Compiler.Incremental

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def terminate_file_process(file) do
    DynamicSupervisor.terminate_child(__MODULE__, Process.whereis(file |> String.to_atom()))
    :ok
  end

  def get_or_create_file_process(file) do
    DynamicSupervisor.start_child(__MODULE__, {Incremental.Node, file: file})
    |> case do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid

      {:error, _reason} ->
        raise "Failed to retrieve or locate file process for #{file}"
    end
  end
end
