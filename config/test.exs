import Config

config :extatic, :input, Path.join(Path.dirname(__DIR__), "test/fixture/site")
config :extatic, :output, Path.join(Path.dirname(__DIR__), "._test_site")
