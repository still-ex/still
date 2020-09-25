# Still

Still is a static site generator for Elixir. It's designed to be easy to use and extend. It works on any project structure with little configuration. Still is JavaScript free.

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

## Documentation

Still works by compiling any file in the input directory, that matches an expression, into the output folder. By default, it looks for files with the extensions `.eex`, `.slime`, `.md` and `.css`.

This document is not complete, but [our website](./priv/site) uses most of the features available in Still. Please have a look there if what you're looking for is not documented.

### Development

In development, you run `iex -S mix still.dev` and still makes your website available in [http://localhost:3000](http://localhost:3000/). Still will be watching the the input folder for changes, refreshing the browser when necessary.

### Compilation

To compile the site run `mix still.compile`.

### Preprocessors

Any file in the input folder with the extensions `.eex`, `.slime`, `.md` and `.css` will be compiled and placed with a different extension in the output folder. Markdown and CSS files run through EEx first, which means you can use EEx syntax in those files. Here's an example of a markdown file that uses EEx interpolation:

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

#### Setting variables

Inside you can also use the `get` and `set` functions to move information around. For instance, you can do something like this in your `index.slime`:

```slime
---
layout: _layout.slime
title: Still | About
---
= include("_includes/header.slime")

- set :hacker_message do
  span style="color: green"
    | Become a hacker!

= link to: "https://hackertyper.net" do
  = get :hacker_message
```

The "Become a hacker" span with a green color will show up inside the `a`. But you can reference that same variable in the `_layout_slime` or the `_includes/header.slime`.

For instance, in `_layout.slime` you can do something like this:

```slime
doctype html
html
  head
    title
      = get :hacker_message
  body
    = children
```

It will look all messed up, but you can do it.

## About

Still was created and is maintained with :heart: by [Subvisual](http://subvisual.com).

![Subvisual](https://raw.githubusercontent.com/subvisual/guides/master/github/templates/logos/blue.png)

## License

Still is released under the [ISC License](./LICENSE).
