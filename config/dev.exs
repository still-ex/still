import Config

config :still,
  dev_layout: true,
  base_url: "http://localhost:3000",
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  pass_through_copy: [~r/.*jpe?g/, "subvisual.png", "fonts"]
