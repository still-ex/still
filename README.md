# Still

🚧 **This package is still in progress - _badumm tss_**

[Documentation][docs]

Still is a static site generator for Elixir.

We designed Still to be simple to use and easy to extend.

There's no JavaScript.

For more information please read the [documentation][docs].

## Installation

To install Still you add it to your dependency list. You should be able to
add it to any mix project.

### For new projects

Run `mix archive.install hex still` to install the archive on your system.

Afterwards, create a static site by running `mix still.new my_site`.
That's it!

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

![Subvisual][sub-logo]

## License

Still is released under the [ISC License](./LICENSE).

[docs]: https://subvisual.github.io/still/
[sub-logo]: https://raw.githubusercontent.com/subvisual/guides/master/github/templates/logos/blue.png
