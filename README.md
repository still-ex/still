# Still

[Documentation](https://subvisual.github.io/still/)

Still is a static site generator for Elixir.

We designed Still to be simple to use and easy to extend.

There's no JavaScript.

For more information please read the <%= link "documentaton", to: "/docs" %>.

## Installation

### For new projects

`mix archive.install hex still` to install it on your system. You only need to do this once.

Then you can create new static websites by running `mix still.new my_site`. That's it!

### Adding to an existing project

Add `still` as a dependency in `mix.exs`:

```elixir
def deps do
  [
    {:still, "~> 0.0.1"}
  ]
end
```

Open up `config.exs` and set the input and output folders:

```elixir
config :still,
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site")
```

Create a file `index.slime` in the input folder.

For more information please visit the [website](https://subvisual.github.io/still/).

## About

Still was created and is maintained with :heart: by [Subvisual](http://subvisual.com).

![Subvisual](https://raw.githubusercontent.com/subvisual/guides/master/github/templates/logos/blue.png)

## License

Still is released under the [ISC License](./LICENSE).
