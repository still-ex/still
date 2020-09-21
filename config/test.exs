import Config

config :still, :input, Path.join(Path.dirname(__DIR__), "test/fixture/site")
config :still, :output, Path.join(Path.dirname(__DIR__), "._test_site")
