defmodule Still.Application do
  use Application

  require Logger

  def start(_type, _args) do
    # Some templating engines need to redefine a module every time a particular
    # file is rendered.
    Code.compiler_options(ignore_module_conflict: true)

    children = base_children() ++ server_children()
    opts = [strategy: :one_for_one, name: Still.Supervisor]

    if server?() do
      Logger.info("Starting development server on port http://localhost:#{port()}")
    end

    Supervisor.start_link(children, opts)
  end

  defp base_children do
    [Still.Compiler.Supervisor]
  end

  defp server_children do
    if server?() do
      [
        {
          Plug.Cowboy,
          scheme: :http, plug: {Still.Web.Router, []}, port: port(), dispatch: cowboy_dispatch()
        },
        Still.Watcher,
        Still.Web.BrowserSubscriptions
      ]
    else
      []
    end
  end

  defp cowboy_dispatch do
    [
      {:_,
       [
         {"/ws", Still.Web.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Still.Web.Router, []}}
       ]}
    ]
  end

  defp port do
    System.get_env("PORT", "3000")
    |> String.to_integer()
  end

  defp server? do
    Application.get_env(:still, :server, false)
  end
end
