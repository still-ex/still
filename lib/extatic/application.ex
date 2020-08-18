defmodule Extatic.Application do
  use Application

  require Logger

  def start(_type, _args) do
    # Some templating engines need to redefine a module every time a particular
    # file is rendered.
    Code.compiler_options(ignore_module_conflict: true)

    Logger.info("Starting development server on port http://localhost:#{port()}")

    children = [
      Extatic.Collections,
      {
        Plug.Cowboy,
        scheme: :http, plug: {Extatic.Router, []}, port: port(), dispatch: dispatch()
      },
      Extatic.FileRegistry,
      Extatic.Watcher
    ]

    opts = [strategy: :one_for_one, name: Extatic.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Extatic.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Extatic.Router, []}}
       ]}
    ]
  end

  defp port do
    System.get_env("PORT", "3000")
    |> String.to_integer()
  end
end
