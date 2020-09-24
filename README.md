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

Still works by compiling any file in the input directory, that matches an expression, into the output folder. By default, it looks for files with the extensions `.eex`, `.slime`, `.md` and `.css`.

This document is not complete, but [our website](./priv/site) uses most of the features available in Still. Please have a look there if what you're looking for is not documented.

### Development

In development mode, when you run `iex -S mix still.dev`, Still watches the input folder for changes and refreshes the browser when necessary. After you start Still, your website should be available in [http://localhost:3000](http://localhost:3000/).

### Preprocessors

Any file in the input folder with the extensions `.eex`, `.slime`, `.md` and `.css` will be compiled and placed with a different extension in the output folder. Markdown and CSS files run through EEx first, which means you can use EEx syntax in those files. For instance:

```markdown
# Some title
<%= link "Some link", to: "somewhere" %>
```

#### Custom preprocessors

If the default preprocessors are not enough, you can add your own. Take the following example:

```elixir
defmodule SiteTest.Js do
  use Still.Preprocessor

  @impl true
  def render(content, variables) do
    %{content: content, variables: variables}
  end
end
```

This preprocessor is a regular module that calls `use Still.Preprocessor` and implements the `render/2` function. The render function is used to transform the content and the variables of a file.

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

For our example preprocessor, we can simply add it to the list in the configuration file:

```elixir
config :still,
  preprocessors: %{
    ".js" => [SiteTest.Js]
  }
```

This preprocessor doesn't do anything to the contents of a file, so the file on the output folder will look exactly like the file in the input folder.

### Pass through copy

If you only want to copy files from the input to the output folder you can use the pass through copy. This is a mechanism where you can specify a string or regular expression and any file that matches will be copied over.

If you specify a string any file, or folder, that matches that string, or starts with that string, will be copied over to the output folder. For instance, if you write this:

```elixir
config :still,
  pass_through_copy: ["img/logo.png"]
```

The file `logo.png` inside the `img` folder will be copied. But if you write this:

```elixir
config :still,
  pass_through_copy: ["img"]
```

Any file or folder that starts with `img` will be copied, which may include an `img` folder or a file named `image.png`. So you need to be mindfull of that.

You can also specify a regular expression, and if a file, or path, matches that expression, it's copied over. For instance:

```elixir
config still,
  pass_through_copy: [~r/.*jpg/]
```

This configuration will copy any file with a `.jpg` extension.

There's another, more advanced functionality, which is to specify a keyword, and the key will be used to match the input folder, and the value will be use to replace the input path. For instance:

```elixir
config :still,
  pass_through_copy: [css: "styles"]
```

Will copy the `css` folder from the input folder but will rename it to `styles` in the output folder.

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
