# Configuration

## Pass through copy

Some files you don't need to transform, only to copy from the input to the output. That's what pass through copy is for.

In your configuration files, if you specify a string on the `pass_through_copy` key, any file, or folder, whose relative path starts with that same string will be copied over to the output.

```elixir
config :still,
  pass_through_copy: ["img/logo.png"]
```

In the example above, the file `logo.png` inside the `img` folder will be copied to the `img` folder in the output. But if you write something like this:

```elixir
config :still,
  pass_through_copy: ["img"]
```

Any file or folder that starts with the string `img` will be copied, which may include an `img` folder or a file named `img.png`. So you need to be mindful of that.

You can also use regular expressions:

```elixir
config still,
  pass_through_copy: [~r/.*\.jpe?g/]
```

The example above will will copy any file with a `.jpg` or `.jpeg` extension.

Sometimes you want to alter the file name or path but keep the content of the files. The `:pass_through_copy` option allows if you use tuples. The key will be used to match the input folder, and the value will be used to transform the input path:

```elixir
config :still,
  pass_through_copy: [css: "styles"]

  # this is also valid:
  # config :still,
  #   pass_through_copy: [{"css", "styles"}]
```

In the example above, the `css` folder from the input folder but will be renamed to `styles` in the output folder.
