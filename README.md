# Still

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `still` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:still, "~> 0.1.0"}
  ]
end
```

If you're starting a project from scratch, run:

```
mix new your_site
cd your_site
mkdir -p priv/site
touch priv/site/index.slime
```

Now open up `config.exs` and add the following:

```
config :still, :input, Path.join(Path.dirname(__DIR__), "priv/site")
config :still, :output, Path.join(Path.dirname(__DIR__), "_site")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/still](https://hexdocs.pm/still).

## Development

```
mix run --no-halt
```

or

```
iex -S mix
```
