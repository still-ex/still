defmodule Extatic.Context.Registry do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def terminate_contexts_for(file) do
    suffix = build_suffix(file)

    pids =
      Process.registered()
      |> Enum.filter(fn name ->
        name
        |> Atom.to_string()
        |> String.starts_with?(suffix)
      end)
      |> Enum.map(&Process.whereis/1)

    for pid <- pids, do: DynamicSupervisor.terminate_child(__MODULE__, pid)

    :ok
  end

  def get_or_start(file, ctx) do
    name = build_name(file, ctx)

    DynamicSupervisor.start_child(__MODULE__, {Extatic.Context, name: name})
    |> case do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid

      {:error, _reason} ->
        raise "Failed to retrieve or locate context #{name}"
    end
  end

  defp build_suffix(file), do: "#{Extatic.Context}::#{file}"

  defp build_name(file, ctx_name), do: :"#{build_suffix(file)}::#{ctx_name}"
end
