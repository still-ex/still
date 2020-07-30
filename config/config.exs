import Config

config :extatic, :input, Path.join(Path.dirname(__DIR__), "priv/site")
config :extatic, :output, Path.join(Path.dirname(__DIR__), "_site")

config :extatic, :reload_msg, "reload"
