defmodule Mix.Tasks.Still.Dev do
  @moduledoc """
  Starts the development server.
  Your website will be available in <http://localhost:3000>.

  Still is watching your file system for changes and it refreshes the browser when necessary.
  If there are any errors building the website, they will show up on the browser, along with the stack trace and the context where the error happened.

  If you run `iex -S mix still.dev` you'll get an interactive shell where you can test things quickly, such as API calls.

  Accepts the same command-line arguments as `mix run`.
  """
  use Mix.Task

  @shortdoc "Starts the development server"

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
