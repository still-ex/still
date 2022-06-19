# Preprocessors

Preprocessors are the cornerstone of Still. A preprocessor chain can take a markdown file, extract metadata from its frontmatter, execute its embedded Elixir, transform it into HTML and wrap it in a layout.

The default preprocessors are in `Still.Preprocessor`. Each file in the input folder with one of the declared extensions is transformed and placed in the same relative place in the output folder. For instance, the file `about.md` will become `about.html` in the output folder. A file in a subfolder, such as `blog/post_1.md`, will be in the same subfolder on the output directory: `blog/post_1.html`. See `Still.Preprocessor.OutputPath` if you need to override this behaviour.

Notice that many file types, such as markdown and CSS, run through EEx, which means you can use EEx syntax in those files. Here's an example of a CSS file that uses EEx interpolation:

```css
html,
body {
  color: <%= Colors.white() %>;
}
```

**Files, or folders, that start with an underscore are ignored by the compilation step.** These files can be set to run through the pass-through copy, or used as layouts and partials for other files.

### Custom preprocessors

If the default preprocessors are not enough, you can extend Still with your own. Take the following example:

```elixir
defmodule YourSite.JPEG do
  use Still.Preprocessor

  alias Still.SourceFile

  @impl true
  def render(%SourceFile{} = source_file) do
    %{source_file | extension: ".jpeg"}
  end
end
```

**A custom preprocessor is a module that calls `use Still.Preprocessor` and implements the `render/1` function.** In this example, the `render` function is used to transform the metadata of a `Still.SourceFile`.

**Preprocessors are a transformation chain** where the output of one preprocessor is used as the input of the next.
See `Still.Preprocessor` for the default chains.

To use the preprocessor defined above, add it to the config:

```elixir
config :still,
  preprocessors: %{
    ".jpeg" => [YourSite.JPEG]
  }
```

This preprocessor doesn't do anything to the contents of a file, so the file on the output folder will look exactly like the file in the input folder.

You can also override a custom chain using existing preprocessors mixed up with your own:

```elixir
config :still,
  preprocessors: %{
    ".css" => [AddContent, EEx, MyPreProcessor, CSSMinify, OutputPath, URLFingerprinting, AddLayout, Save]
  }
```

**The preprocessors will be executed in the order you configure them.**
