defmodule Mix.Tasks.Still.Dev do
  use Mix.Task

  @doc false
  def run(_) do
    Application.put_env(:still, :server, true, persistent: true)
    Mix.Tasks.Run.run(args())
  end

  defp args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
