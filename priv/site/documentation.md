---
layout: "_post_layout.slime"
permalink: docs.html
title: "Documentation"
---

If you're here just to see some code, you can explore the [source code for this website](https://github.com/subvisual/still/tree/master/priv/site). You can also run it in your machine: clone the repository, install the dependencies `mix deps.get` and run the development server `iex -S mix still.dev`.

Still takes files from a source directory, runs them through some preprocessors, and places them in an output directory.

🚧 _This documentation is incomplete, but we built [this website you're reading](https://github.com/subvisual/still/tree/master/priv/site) with Still to showcase some of its features. Have a look there if you can't find what you're looking for here._

## Installation

To install Still you add it to your dependency list. You should be able to add it to any mix project.

### For new projects

Run `mix archive.install hex still` to install the archive on your system.

Afterwards, create a site by running `mix still.new my_site`. That's it!

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

## Development

While you're working on the website, run `iex -S mix still.dev` to start Still in development mode and your website will be available in [http://localhost:3000](http://localhost:3000/). Still will be watching the the input folder for changes, refreshing the browser when necessary.

In development mode we will also show you compile time errors in the browser.

## Production

To compile your site, run `mix still.compile` and the compiled files will be in the output directory. If you're wondering about how to integrate this compilation step with your CI, checkout the []source code for the Github Action that deploys this site](https://github.com/subvisual/still/blob/master/.github/workflows/site.yml) you're reading.

## Preprocessors

Preprocessors are the cornerstone of Still. A preprocessor chain can take a markdown file, execute its embedded Elixir, extract metadata from its front matter, transform it into HTML and wrap it in a layout.

The default preprocessors are declared in the [_Preprocessor_ module](https://github.com/subvisual/still/blob/master/lib/still/preprocessor.ex#L16). Each file in your input directory with one of the declared extensions will be transformed and placed in the same relative directory in the output folder. For instance, the file `about.md` will become `about.html` in the output folder, and a file inside a folder `blog/post_1.md` will also be in the same folder on the output directory `blog/post_1.html`.

Notice that many file types, such as markdown and CSS , run through EEx, which means you can use EEx syntax in those files. Here's an example of a CSS file that uses EEx interpolation:

```css
html,
body {
  color: <%%= Colors.white() %>;
}
```

**Files, or folders, that start with an underscore are ignored by the compilation step.** These files can be set to run through the pass-through copy, or used as layouts and partials for other files.

### Custom preprocessors

If the default preprocessors are not enough, you can extend Still with your own. Take the following example:

```elixir
defmodule YourSite.JPEG do
  use Still.Preprocessor

  @impl true
  def extension(_), do: ".jpeg"

  @impl true
  def render(file) do
    file
  end
end
```

This preprocessor is a module that calls `use Still.Preprocessor` and implements the `render/2` and `extension/1` functions. The _render_ function is used to transform the content and the variables of a file, and the _extension_ function is used to set the resulting content type. This _extension_ function is not mandatory.

Preprocessors are always part of a transformation chain, and each file will run through the chain, using the output of the one preprocessor as the input of the next. At the moment, the default transformation chains look like this:

```elixir
@default_preprocessors %{
  ".slim" => [Frontmatter, Slime, OutputPath],
  ".slime" => [Frontmatter, Slime, OutputPath],
  ".eex" => [Frontmatter, EEx, OutputPath],
  ".css" => [EEx, CSSMinify, OutputPath, URLFingerprinting],
  ".js" => [EEx, JS, OutputPath, URLFingerprinting],
  ".md" => [Frontmatter, EEx, Markdown, OutputPath]
}
```

You can see that some files go through a front matter preprocessor, and CSS goes through EEx, which allows for the interpolation mentioned above.

For the example preprocessor defined above, we can add it to the list in the configuration file:

```elixir
config :still,
  preprocessors: %{
    ".jpeg" => [YourSite.JPEG]
  }
```

This preprocessor doesn't do anything to the contents of a file, so the file on the output folder will look exactly like the file in the input folder.

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

## Layouts

Layouts wrap other content. To use a layout, set the `layout` key in front matter. For instance:

```slime
---
layout: _layout.slime
---

h1 About Page
```

This will look for `_layout.slime` in your input folder.

The layout file must print the children variable. For instance:

```slime
doctype html
html
  body
    = children
```

Notice that `_layout.slime` starts with an underscore. This is because we don't
want to compile the layout file to the output.

In fact, any file starting with an underscore isn't compiled to the output, but can be imported by other files.

## Collections

Collections allow you to group multiple files. For instance:

```
---
tags: post
title: A blog post
---
```

Every file that specifies the `post` tag will be listed in the `post` collection.
You can then iterate over this list by accessing the `collections` variable:

```slime
ul
  = Enum.map Map.get(collections, "post", []), fn x ->
    li
      = link x[:title], to: x[:permalink]
```

## View helpers

### Including other files

In any file, you can use the `include` function to import the contents of a different file. As an example:

```slim
html
  head
    = include "_includes/head.slim"
  body
    = children
```

### Link to other files

In any file you can call the `link` function to create a link to somewhere
else. This function will already take care of specifying the `rel` and `target` when necessary. It supports both relative and absolute paths:

```slim
= link "Home", to: "/"
= link "Blog", to: "https://example.org"
```

### Custom view helpers

To call your own functions from the view files, register a module in the config:

```elixir
config :still,
  view_helpers: [Your.Module]
```

## License

Still is released under the [ISC License](./LICENSE).
