import Config

config :extatic, :reload_msg, "reload"

import_config("#{Mix.env()}.exs")
