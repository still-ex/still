import Config

config :extatic, :reload_msg, "reload"

config :extatic, :template_languages, [".slime"]

import_config("#{Mix.env()}.exs")
