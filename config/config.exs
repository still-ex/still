import Config

config :still,
  view_helpers: []

import_config("#{Mix.env()}.exs")
