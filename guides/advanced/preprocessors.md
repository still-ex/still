# Preprocessors

Preprocessors are the cornerstone of Still. A preprocessor chain can take a markdown file, execute its embedded Elixir, extract metadata from its front matter, transform it into HTML and wrap it in a layout.

The default preprocessors are in the [`Preprocessor` module](https://github.com/subvisual/still/blob/master/lib/still/preprocessor.ex#L16). Each file in the input folder with one of the declared extensions is transformed and placed in the same relative place in the output folder. For instance, the file `about.md` will become `about.html` in the output folder, and a file inside a folder `blog/post_1.md` will also be in the same folder on the output directory `blog/post_1.html`.

Notice that many file types, such as markdown and CSS, run through EEx, which means you can use EEx syntax in those files. Here's an example of a CSS file that uses EEx interpolation:

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

**A custom preprocessor is simply a module that calls `use Still.Preprocessor` and implements the `render/2` and `extension/1` functions.** In this example, the `render` function is used to transform the content and the metadata of a file, and the `extension` function is used to set the resulting content type. This `extension` function is not mandatory.

**Preprocessors are always part of a transformation chain** and each file will run through the chain, using the output of the one preprocessor as the input of the next. At the moment, the default transformation chains look like this:

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

If you want to add a custom preprocessor to one of the default extensions, you need to redefine the whole pipeline. For example, if you want to add your own preprocessor for `.css` files but keep the existing ones do the following:

```elixir
config :still,
  preprocessors: %{
    ".css" => [EEx, MyPreProcessor, CSSMinify, OutputPath, URLFingerprinting]
  } 
\`\`\`

The preprocessors will be executed in the order you configure them.

If you want to add a custom preprocessor to one of the default extensions, you need to redefine the whole pipeline. For example, if you want to add your own preprocessor for `.css` files but keep the existing ones do the following:

```elixir
config :still,
  preprocessors: %{
    ".css" => [EEx, MyPreProcessor, CSSMinify, OutputPath, URLFingerprinting]
  } 
