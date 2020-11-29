defmodule Still.Web.SocketHandler do
  @behaviour :cowboy_websocket

  require Logger

  alias Still.Compiler.FileErrorsCache
  alias Still.Web.BrowserSubscriptions

  def init(request, _state) do
    state = %{registry_key: request.path}

    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    if message == "subscribe" do
      Logger.debug("Browser subscribing for changes")
      BrowserSubscriptions.add(self())

      FileErrorsCache.get_errors()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.reject(&is_nil(&1))
      |> case do
        [] ->
          :ok

        [error | _] ->
          send(self(), Jason.encode!(%{type: "error", data: format_error(error)}))
      end
    end

    {:ok, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  defp format_error(e) do
    details =
      e.stacktrace
      |> Enum.reduce("", fn {mod, fun, arity, args}, acc ->
        acc <>
          "<div><strong>#{mod}</strong> #{fun} #{arity} <em>#{inspect(args, pretty: true)}</em></div>"
      end)

    """
    <div class='dev-error'>
      <h1>#{e.source_file.input_file} #{e.message}</h1>
      <h2>Stacktrace</h2>
      <pre>
        <code>
    #{details |> String.trim()}
        </code>
      </pre>
      <h2>Context</h2>
      <pre>
        <code>
    #{inspect(e, pretty: true) |> String.trim()}
        </code>
      </pre>
      </details>
    </div>
    """
  end
end
