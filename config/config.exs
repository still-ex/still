import Config

config :still,
  view_helpers: [],
  dev_layout: false,
  url_fingerprinting: false

import_config("#{Mix.env()}.exs")
