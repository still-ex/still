import Config

config :extatic,
  base_url: "http://localhost:3000",
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  javascripts: Path.join(Path.dirname(__DIR__), "assets"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  pass_through_copy: [~r/.*jpg/, "logo.jpg"]
