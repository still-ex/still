defmodule Still.Web.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  import Still.Utils

  plug(Plug.Logger, log: :debug)
  plug(Plug.Static, from: "_site", at: "/")
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_header("Content-Type", "text/html; charset=UTF-8")
    |> send_file(200, Path.join(get_output_path(), "index.html"))
  end

  get "*path" do
    if not send_file(conn, "#{Path.join(get_output_path(), Path.join(path))}/index.html") and
         not send_file(conn, "#{Path.join(get_output_path(), Path.join(path))}.html") do
      conn
      |> send_resp(404, "File not found")
    end
  end

  defp send_file(conn, file) do
    if File.exists?(file) do
      conn
      |> put_resp_header("Content-Type", "text/html; charset=UTF-8")
      |> send_file(200, file)

      true
    else
      false
    end
  end
end
