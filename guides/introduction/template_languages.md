# Template Languages

The following sections contain more information on the templating languages supported by default and how to add your own.

## Slime

[Slime](https://github.com/slime-lang/slime) is a language that generates HTML. Any file with the extension `.slime` will generate a corresponding `.html` file. More information can be found in [Template](https://hexdocs.pm/still/templates.html).

## EEx

[EEx](https://hexdocs.pm/eex/EEx.html) is not a language, but a tool to embed Elixir code in strings. Files with the `.eex` extension will generate `.html` files (unless you override that configuration). However, almost every template runs first through EEx, which means that you can use EEx inside Front Matter blocks, Markdown, CSS, JS and almost any other file. More information can be found in [Template](https://hexdocs.pm/still/templates.html).

## Markdown

Files with the extension `.md` will be treated as Markdown and generate `.html` files. You can using Elixir in your markdown files with EEx:

```md
---
tags:
  - post
---

# Post 1

<%= responsive_image("bg.jpg") %>
```

More information can be found in [Template](https://hexdocs.pm/still/templates.html).

## CSS

CSS files are regular [templates](https://hexdocs.pm/still/templates.html) where you can embed Elixir:

```css
<%= include("_global.scss") %>

@font-face {
  font-family: IBMPlexMono;
  src: url(<%= url_for("/fonts/IBMPlexMono-Regular.ttf") %>);
}
```

## JavaScript

JavaScript files are regular [templates](https://hexdocs.pm/still/templates.html) where you can embed Elixir:

```js
console.log('<%= link_to("img/bg.jpg") %>')
```

## Custom

To add your own templating language you need to write at least one [custom preprocessor](https://hexdocs.pm/still/preprocessors.html). Say you want to add [Sass](https://sass-lang.com/) using [these Elixir bindings](https://github.com/scottdavis/sass.ex). The first step is to add the package to the dependencies:

```elixir
  defp deps do
    [
      ...
      {:sass, git: "https://github.com/scottdavis/sass.ex", submodules: true},
    ]
  end

```

Then, you create a new Elixir module somewhere with the following contents:

```elixir
defmodule YourSite.SassPreprocessor do
  use Still.Preprocessor

  # overrides the file's extension
  @impl true
  def extension(_) do
    ".css"
  end

  @impl true
  def render(file) do
    {:ok, content} =
      Still.Utils.get_input_path(file.input_file)
      |> Sass.compile_file()

    %{file | content: content}
  end
end
```

You should read the section on [custom preprocessors](https://hexdocs.pm/still/preprocessors.html#content) for more information.

The last step is update `config.exs`:

```elixir
alias Still.Preprocessor.{
  OutputPath,
  Save,
  AddContent
}

config :still,
  preprocessors: %{
    ".scss" => [AddContent, YourSite.SassPreprocessor, OutputPath, Save]
  }
```

Now, any file with the extension `.scss` will be compiled with Sass and generate a `.css` file.
