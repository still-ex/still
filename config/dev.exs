import Config

config :extatic,
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  base_url: "http://localhost:4000",
  pass_through_copy: [
    {"css", "styles"},
    ~r/.*jpg/,
    "logo.jpg"
  ]
