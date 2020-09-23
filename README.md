# Still

Still is a simple static site generator for Elixir inspired by
[Eleventy](https://www.11ty.dev/docs/). Still will work with any project
structure with little configuration. This project is JavaScript free.

## Installation

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

Create a file `index.slime` in the input folder and run `mix still.dev`.

To compile the whole site run `mix still.compile`.

## Documentation

The documentation is not perfect, but [the website](./priv/site) should be
a fine example of what you can do with Still.

### Development

In development, when you run `mix still.dev`, Still watches the file
system for changes and refreshes the browser when necessary. This only works for
changes in your input folder, if you're extending Still, changes to the Elixir
code will not trigger a refresh.

### Preprocessors

Still works with [EEx](https://elixirschool.com/en/lessons/specifics/eex/) and
[Slime](https://github.com/slime-lang/slime), and CSS by default. Any file with
a `.eex`, `.slime` or `.css` extension will be automatically converted and
placed on the output folder.

We run the CSS files through EEx which mean you can use EEx interpolation
inside CSS files.

#### Custom preprocessors

To write a custom preprocessor first define a module that uses
`Still.Preprocessor`, for instance:

```elixir
defmodule SiteTest.Js do
  use Still.Preprocessor

  @impl true
  def render(content, variables) do
    %{content: content, variables: variables}
  end
end
```

A preprocessor must implement the `render/2` function which receives the
content of a file and its context. In this function you can transform both the
contents and the variables, returning both of them for the next preprocessor.

Then, in your configuration you must specify an object that matches an
extension to a list of preprocessors. For instance:

```elixir
config :still,
  preprocessors: %{
    ".js" => [SiteTest.Js]
  }
```

In this example we created a preprocessor that simply copies files `.js` files
from the input to the output folder.

### Pass through copy

You can extend Still with preprocessors, but sometimes you only want to copy
files over. For those situations you can use the pass through copy.

The following example covers all the supported configurations:

```elixir
config still,
  pass_through_copy: [~r/.*jpg/, "logo.png", css: "styles"]
```

In this example, we'll copy every file that has the `.jpg` extension, the
`logo.png` file, and the `css` folder, but the `css` will be called `styles` in
the output folder.

You can write a regex, a file path, or a keyword list where value is the
destination name.

### Layouts

Layouts can be used to wrap other content. To wrap the contents of a file in
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

### Collections

Collections allow you to group multiple files. For instance:

```
---
tags: post
title: A blog post
---
```

Every file that specifies the `post` tag will be listed in the `post` collection.
You can then iterate over this list doing something like this:

```slime
ul
  = Enum.map Map.get(collections, "post", []), fn x ->
    li
      = link x[:title], to: x[:permalink]
```

### View helpers

#### Including other files

In any template you can access a `include` function that imports the contents
of one file into another.

#### Link to other files

In any template you call the `link` function to create a link to somewhere
else. This function will already take care of specifying the `rel` and `target`
when necessary.

## About

Still was created and is maintained with :heart: by [Subvisual][subvisual].

[![Subvisual][subvisual-logo]][subvisual]

[subvisual]: http://subvisual.com
[subvisual-logo]: https://raw.githubusercontent.com/subvisual/guides/master/github/templates/logos/blue.png

## License

Still is released unde the [ISC License](./LICENSE).
