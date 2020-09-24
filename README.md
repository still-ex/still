# Still

Still is a static site generator for Elixir inspired by [Eleventy](https://www.11ty.dev/docs/). It works with any project structure with little configuration. Still is JavaScript free.

## Installation

**TODO:** Add instruction on how to use the generator.

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

Still works by compiling any file in the input directory that matches a valid extension into the output folder. By default, it looks for `.eex`, `.slime`, `.md` and `.css`.

The documentation is not complete, but [our website](./priv/site) uses most of the features available. Please look there if what you're looking for is not documented.

### Development

In development mode, when you run `iex -S mix still.dev`, Still watches the input folder for changes and refreshes the browser when necessary. After you start Still, your website should be available in [http://localhost:3000](http://localhost:3000/).

### Preprocessors

Any file in the input folder with the extensions `.eex`, `.slime`, `.md` and `.css` will be compiled and placed using the same name (but a different extension) in the output folder. Markdown and CSS files run through EEx first, which means you can use EEx syntax in those files.

#### Custom preprocessors

If necessary, you can add your own preprocessors. Take the following example:

```elixir
defmodule SiteTest.Js do
  use Still.Preprocessor

  @impl true
  def render(content, variables) do
    %{content: content, variables: variables}
  end
end
```

This preprocessor is a regular module that calls `use Still.Preprocessor` and implements the `render/2` function. In the `render/2` function any preprocessor can transform both the content and the variables.

Preprocessors usually run in chains, so the output of one preprocessor will be the input of another.

Finally, in your configuration file you must specify a map that matches an extension to a list of preprocessor.

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

Still was created and is maintained with :heart: by [Subvisual](http://subvisual.com).

![Subvisual](https://raw.githubusercontent.com/subvisual/guides/master/github/templates/logos/blue.png)

## License

Still is released under the [ISC License](./LICENSE).
