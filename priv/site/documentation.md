---
layout: "_post_layout.slime"
permalink: docs.html
title: "Documentation"
---

Still works by compiling files from an input directory into an output directory. By default, it looks for files with the extensions `.eex`, `.slime`, `.md` and `.css`, but continue reading to see how you set it up to your needs.

_This document is not complete, but [our website](./priv/site) uses most of the features available in Still. Please have a look there if you can't find what you're looking for._

## Installation

### For new projects

Run `mix archive.install hex still` to install Still in your system. You only need to do this once.

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

## Development

While you're developing the website, run `iex -S mix still.dev` to start Still in development mode.
Your website will be available in [http://localhost:3000](http://localhost:3000/) and Still will be watching the the input folder for changes, refreshing the browser when necessary.

## Compilation

To compile the site run `mix still.compile`.

## Preprocessors

Any file with one of the extensions listed above will be compiled and placed in the same relative path (but with a different extension) in the output folder.

Markdown and CSS files run through EEx first, which means you can use EEx syntax in those files. Here's an example of a markdown file that uses EEx interpolation:

```markdown
# Some title

<%= link "Some link", to: "somewhere" %>
```

Files, or folders, that start with an underscore are ignored by the compilation step.

### Custom preprocessors

If the default preprocessors are not enough, you can extend Still with your own. Take the following example:

```elixir
defmodule SiteTest.Js do
  use Still.Preprocessor

  @impl true
  def render(content, variables) do
    %{content: content, variables: variables}
  end
end
```

This preprocessor is a module that calls `use Still.Preprocessor` and implements the `render/2` function. This function is used to transform the content and the variables of a file.

Preprocessors are always part of a transformation chain, and each file will run through the chain, using the output of the one preprocessor as the input of the next. At the moment, the default transformation chains look like this:

```elixir
@default_preprocessors %{
  ".slim" => [Preprocessor.Frontmatter, Preprocessor.Slime],
  ".slime" => [Preprocessor.Frontmatter, Preprocessor.Slime],
  ".eex" => [Preprocessor.Frontmatter, Preprocessor.EEx],
  ".css" => [Preprocessor.EEx, Preprocessor.CSSMinify]
}
```

You can see that some files go through a front matter preprocessor, and CSS goes through EEx, which allows for the interpolation mentioned above.

For the example preprocessor defined above, we can add it to the list in the configuration file:

```elixir
config :still,
  preprocessors: %{
    ".js" => [SiteTest.Js]
  }
```

This preprocessor doesn't do anything to the contents of a file, so the file on the output folder will look exactly like the file in the input folder.

## Pass through copy

Some files you don't want to compile, only to copy from the input to the output. That's what pass through copy is for.

In your configuration files, if you specify add string on the `pass_through_copy` key, any file, or folder, whose relative path starts with that same string will be copied over to the output.

```elixir
config :still,
  pass_through_copy: ["img/logo.png"]
```

In the example above, the file `logo.png` inside the `img` folder will be copied to the `img` folder in the output. But if you write something like this:

```elixir
config :still,
  pass_through_copy: ["img"]
```

Any file or folder that starts with the string `img` will be copied, which may include an `img` folder or a file named `img.png`. So you need to be mindfull of that.

You can also use regular expression:

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

In the example above, the `css` folder from the input folder but will be renamed to `styles` in the output folder.

## Layouts

Layouts can be used to wrap other content. To wrap the contents of a file with
a layout template, use the `layout` key in front matter. For instance:

```slime
---
layout: _layout.slime
---

h1 About Page
```

This will look for `_layout.slime` in your input folder.

The layout file must print the children variable, for instance:

```slime
doctype html
html
  body
    = children
```

Notice that `_layout.slime` starts with an underscore. This is because we don't
want to compile the layout file to the output.

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

### Link to other files

In any file you can call the `link` function to create a link to somewhere
else. This function will already take care of specifying the `rel` and `target`
when necessary. It supports both relative and absolute paths:

```slim
= link "Home", to: "/"
= link "Blog", to: "https://example.org"

## License

Still is released under the [ISC License](./LICENSE).
