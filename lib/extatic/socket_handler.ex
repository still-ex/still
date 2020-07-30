defmodule Extatic.SocketHandler do
  @behaviour :cowboy_websocket

  require Logger

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
      Extatic.Watcher.subscribe(self())
    end

    {:ok, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
