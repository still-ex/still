import Config

config :still,
  base_url: "http://localhost:3000",
  input: Path.join(Path.dirname(__DIR__), "test/fixture/site"),
  output: Path.join(Path.dirname(__DIR__), "._test_site"),
  compilation_timeout: 45000
