defmodule Mix.Tasks.Extatic.Dev do
  use Mix.Task

  @doc false
  def run(_) do
    Application.put_env(:extatic, :server, true, persistent: true)
    Mix.Tasks.Run.run(args())
  end

  defp args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
