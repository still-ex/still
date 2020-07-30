# Extatic

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `extatic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:extatic, "~> 0.1.0"}
  ]
end
```

If you're starting a project from scratch, run:

```
mix new your_site --sup
cd your_site
mkdir -p priv/site
touch priv/site/index.slime
```

Now open up `config.exs` and add the following:

```
config :extatic, :input, Path.join(Path.dirname(__DIR__), "priv/site")
config :extatic, :output, Path.join(Path.dirname(__DIR__), "_site")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/extatic](https://hexdocs.pm/extatic).

## Development

```
mix run --no-halt
```

or

```
iex -S mix
```
