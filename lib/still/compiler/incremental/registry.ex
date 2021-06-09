defmodule Still.Compiler.Incremental.Registry do
  @moduledoc """
  Supervisor that maps files (based on their name) to PIDs of `Still.Compiler.Incremental.Node`.
  """

  use DynamicSupervisor

  alias Still.Compiler.Incremental

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Terminates the `Still.Compiler.Incremental.Node` corresponding to the given file name.
  """
  def terminate_file_process(file) do
    pid = file |> String.to_atom() |> Process.whereis()

    if not is_nil(pid) do
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end

    :ok
  end

  @doc """
  Attempts to retrive the `Still.Compiler.Incremental.Node` corresponding to the
  given file name. If none exists, a new node is started.
  """
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
