defmodule Extatic.Compiler.Context.Registry do
  use DynamicSupervisor

  alias Extatic.Compiler.Context

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_or_start(file) do
    name = build_name(file)

    DynamicSupervisor.start_child(__MODULE__, {Context, name: name})
    |> case do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid

      {:error, _reason} ->
        raise "Failed to retrieve or locate context #{name}"
    end
  end

  def terminate(file) do
    name = build_name(file)
    pid = Process.whereis(name)

    DynamicSupervisor.terminate_child(__MODULE__, pid)

    :ok
  end

  defp build_name(file), do: :"#{Extatic.Context}::#{file}"
end
