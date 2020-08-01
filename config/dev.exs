import Config

config :extatic,
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  pass_through_copy: [
    {"css", "styles"},
    ~r/.*jpg/,
    "logo.jpg"
  ]
