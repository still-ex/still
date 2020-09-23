import Config

config :still,
  input: Path.join(Path.dirname(__DIR__), "priv/site")
  output: Path.join(Path.dirname(__DIR__), "_site")
