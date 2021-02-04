defmodule Mix.Tasks.Still.Dev do
  use Mix.Task

  @doc false
  def run(_) do
    Application.put_env(:still, :server, true, persistent: true)
    Mix.Tasks.Run.run(args())
  end

  if Code.ensure_loaded?(IEx) do
    defp args do
      if IEx.started?(), do: [], else: ["--no-halt"]
    end
  else
    defp args do
      ["--no-halt"]
    end
  end
end
