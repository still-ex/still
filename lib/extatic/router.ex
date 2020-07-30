defmodule Extatic.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  import Extatic.Utils

  plug(Plug.Logger, log: :debug)
  plug(Plug.Static, from: "_site", at: "/")
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> send_file(200, Path.join(get_output_path(), "index.html"))
  end

  get ":path" do
    file = "#{Path.join(get_output_path(), path)}.html"

    if File.exists?(file) do
      conn
      |> send_file(200, file)
    else
      conn
      |> send_resp(404, "File not found")
    end
  end
end
