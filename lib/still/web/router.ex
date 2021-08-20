defmodule Still.Web.Router do
  @moduledoc false

  alias Still.Compiler.Incremental.OutputToInputFileRegistry

  use Plug.Router
  use Plug.Debugger

  require Logger

  import Still.Utils

  plug(Plug.Logger, log: :debug)
  plug(:reload)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_header("Content-Type", "text/html; charset=UTF-8")
    |> try_send_file(Path.join(get_output_path(), "index.html"))
    |> case do
      :error ->
        %{content: content} = Still.Compiler.File.DevLayout.wrap("")
        send_resp(conn, 200, content)

      other ->
        other
    end
  end

  get "*path" do
    full_path =
      path
      |> Enum.join("/")
      |> String.replace_prefix(get_base_url(), "")
      |> get_output_path()

    with :error <- try_send_file(conn, full_path),
         :error <- try_send_file(conn, "#{full_path}/index.html"),
         :error <- try_send_file(conn, "#{full_path}.html") do
      conn
      |> send_resp(404, "File not found")
    end
  end

  defp try_send_file(conn, file) do
    source_file = OutputToInputFileRegistry.recompile(file)

    cond do
      source_file.content != nil ->
        conn
        |> put_resp_header("content-type", MIME.from_path(file))
        |> send_resp(200, source_file.content)

      File.exists?(file) and not File.dir?(file) ->
        conn
        |> put_resp_header("content-type", MIME.from_path(file))
        |> send_file(200, file)

      true ->
        :error
    end
  end

  def reload(conn, _) do
    Still.Web.CodeReloader.reload()
    conn
  end
end
