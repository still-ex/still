defmodule Extatic.Application do
  use Application

  require Logger

  def start(_type, _args) do
    # Some templating engines need to redefine a module every time a particular
    # file is rendered.
    Code.compiler_options(ignore_module_conflict: true)

    children = base_children() ++ server_children()
    opts = [strategy: :one_for_one, name: Extatic.Supervisor]

    if server?() do
      Logger.info("Starting development server on port http://localhost:#{port()}")
    end

    Supervisor.start_link(children, opts)
  end

  defp base_children do
    [Extatic.Compiler.Supervisor]
  end

  defp server_children do
    if server?() do
      [
        {
          Plug.Cowboy,
          scheme: :http, plug: {Extatic.Router, []}, port: port(), dispatch: cowboy_dispatch()
        },
        Extatic.Watcher
      ]
    else
      []
    end
  end

  defp cowboy_dispatch do
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

  defp server? do
    Application.get_env(:extatic, :server, false)
  end
end
