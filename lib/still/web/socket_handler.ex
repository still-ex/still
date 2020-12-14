defmodule Still.Web.SocketHandler do
  @behaviour :cowboy_websocket

  require Logger

  alias Still.Compiler.ErrorCache
  alias Still.Web.BrowserSubscriptions
  alias Still.Web.ErrorFormatter

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

      ErrorCache.get_errors()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.reject(&is_nil(&1))
      |> case do
        [] ->
          :ok

        [error | _] ->
          send(self(), Jason.encode!(%{type: "error", data: ErrorFormatter.format(error)}))
      end
    end

    {:ok, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
