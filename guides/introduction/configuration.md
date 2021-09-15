# Configuration

## Profiler

There's a rudimentary profiler that you can enable with:

```elixir
config :still,
  profiler: true
```

This will generate an HTML file that can be accessed at `http://localhost:3000/profiler`.

**Enabling the profiler will make the dev server slower and increase the memory usage**. If you're experiencing any performance issues, please disable the profiler.

## Passthrough copy

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

**Any file or folder that starts with the string `img` will be copied, which may include an `img` folder or a file named `img.png`.** So you need to be mindful of that.

You can also use regular expressions:

```elixir
config still,
  pass_through_copy: [~r/.*\.jpe?g/]
```

The example above will will copy any file with a `.jpg` or `.jpeg` extension.

**Sometimes you want to alter the file name or path but keep the content of the files.** The `:pass_through_copy` option allows this by using tuples. The key will be used to match the input folder, and the value will be used to transform the input path:

```elixir
config :still,
  pass_through_copy: [css: "styles"]

  # this is also valid:
  # config :still,
  #   pass_through_copy: [{"css", "styles"}]
```

In the example above, the `css` folder from the input folder but will be renamed to `styles` in the output folder.

## Ignored files

If you want to ignore some files in your input folder, such as files in the `node_modules` folder, or any file containing the word `tailwind`, you can use the setting:

```elixir
config :still,
  ignore_files: ["node_modules", ~r/tailwind/]
```

This setting is similar to [Passthrough copy](#passthrough-copy).

## Watchers

Watchers are external processes managed by Still. You can use watchers to run something like tailwind or webpack. For instance, if the `assets` folder contains your `tailwind.config.js`, the following settings will remove `assets` from the compilation pipeline, and start tailwind on that folder:


```elixir
config :still,
  ignore_files: ["assets"],
  watchers: [
    npx: ["tailwindcss", "-o", "../global.css", "--watch", cd: "priv/site/assets"]
  ]
```

 Tailwind will generate a `global.css` in the root of your website, which will be picked up by Still and turned into a file on your website.