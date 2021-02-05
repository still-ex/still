import Config

config :still,
  dev_layout: false,
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  pass_through_copy: [~r/.*jpe?g/, "subvisual.png", "images", "fonts"],
  url_fingerprinting: false,
  profiler: false,
  view_helpers: []

config :mogrify,
  mogrify_command: [
    path: "mogrify",
    args: []
  ]

config :mogrify,
  convert_command: [
    path: "convert",
    args: []
  ]

import_config("#{Mix.env()}.exs")
