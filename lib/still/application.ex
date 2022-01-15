defmodule Still.Application do
  @moduledoc false

  use Application

  import Still.Utils, only: [config: 2]

  require Logger

  def start(_type, _args) do
    # Some templating engines need to redefine a module every time a particular
    # file is rendered.
    Code.compiler_options(ignore_module_conflict: true)

    children =
      base_children() ++
        server_children() ++
        profiler_children() ++
        process_watchers_children()

    opts = [strategy: :one_for_one, name: Still.Supervisor]

    if server?() do
      Logger.info("Starting development server on port http://localhost:#{port()}")
    end

    Supervisor.start_link(children, opts)
  end

  defp base_children do
    [
      Still.Compiler.Supervisor,
      Still.Data,
      {Cachex, name: Still.Compiler.ContentCache.cache_name()}
    ]
  end

  defp server_children do
    if server?() do
      [
        {
          Plug.Cowboy,
          scheme: :http, plug: {Still.Web.Router, []}, port: port(), dispatch: cowboy_dispatch()
        },
        Still.Watcher,
        Still.Web.BrowserSubscriptions,
        Still.Web.CodeReloader
      ]
    else
      []
    end
  end

  defp profiler_children do
    if profiler?() do
      [Still.Profiler]
    else
      []
    end
  end

  defp process_watchers_children do
    if server?() do
      Enum.map(config(:watchers, []), &{Still.ProcessWatcher, &1})
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
    config(:server, false)
  end

  defp profiler? do
    config(:profiler, false)
  end
end
