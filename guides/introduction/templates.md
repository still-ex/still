# Template

We call template to almost every file in the input folder. These templates
are transformed, and combined, to create the website.

## Helpers

In templates, you can usually write Elixir, which allows you to extend
your site with abstractions to generate CSS or make API calls. Still comes
with some functions out of the box to help you build your website. We call
these view helpers.

### Including other files

Use the `include` function to import the contents of another file. For
instance, the following template includes the file `_includes/head.slime`:

```slim
html
  head
    = include "_includes/head.slime"
  body
    = children
```

Behind the scenes, Still will render `head.slime` to HTML and replace the
function call with its contents.

### Linking to other files

The `link` function creates HTML hyperlinks. It takes care of specifying
the `rel` and `target` when necessary, and it supports both full URLs or
paths relative to the input folder. **You should always use the link
function to create hyperlinks between files, otherwise deploys to
subfolders will not work.** For instance:

```slim
= link "Home", to: "/"
= link "Blog", to: "https://example.org"
```

### Including images

Image support is still (get it?) rudimentary: it can generate images of
different sizes, and apply transformations to them. By default, it relies
on [ImageMagick][imagemagick], but if you add [`imageflow_ex`][imageflow]
as a dependency it will use that. The reason we do not use `imageflow_ex`
by default is that it requires Rust. If you want to use ImageMagick, you
also need to have it installed in your system.

`responsive_image/2` receives an image and some opts and generates an HTML
`img` which with the correct `src` and `sizes` for the different image
sizes it generates.

To insert an image use the `responsive_image` function, which accepts
a list of keyword arguments. To generate an image, Still only cares about the
`:image_opts` key, everything else will be rendered as an attribute on the
`img` tag. `:image_opts` has to be a map where you can specify `:sizes`
and `:transformations`.

The `:sizes` key is optional and by default we take the image's width to generate
3 smaller images. If you specify an array of integers, it will use that
instead.

`:transformations` is also optional, and it's passed down to either
[ImageMagick](imagemagic-cli-option] or [Imageflow][imageflow-docs], see
each project's documentation for more information.

A responsive image can be generated like this:

```eex
<%= responsive_image("example.jpg", image_opts: %{transformations: [grayscale: "Rec709Luma"]}) %>
```

```slime
= responsive_image("cover.jpg", image_opts: %{transformations: [color_filter: "grayscale_bt709"]}, class: "cover")
```

[imagemagick]: https://imagemagick.org/
[imageflow]: https://github.com/imazen/imageflow
[imagemagic-cli-option]: https://imagemagick.org/script/command-line-options.php
[imageflow-docs]: https://docs.imageflow.io/

### Custom helpers

You can call any module from the templates, but if you defined some modules in the config, their functions are imported to the templates:

```elixir
config :still,
  view_helpers: [Your.Module]
```

## Layouts

Layouts are templates that wrap other content. To use a layout, set the
`layout` key in front matter. For instance:

```slime
---
layout: _layout.slime
---

h1 About Page
```

This will look for a `_layout.slime` in your input folder.

The layout file must print the children variable. For instance:

```slime
doctype html
html
  body
    = @children
```

Notice that `_layout.slime` starts with an underscore. **This is necessary
since we don't want to compile the layout file by itself**. Any file
starting with an underscore isn't compiled to the output, but can be
imported by other files.

### More Examples

You can use any templating language in your layout - it doesn't need to
match the language of the content being wrapped. For instance, we can have
a markdown file with a JavaScript wrapper:

```markdown
---
permalink: index.js
layout: _console_layout.js
---

# This is an h1
```

And in `_console_layout.js` we have to render the `children`:

```js
console.log("<%= @chidlren %>");
```

### Layout Chaining

Any file can include a layout, even files that work as layouts. For
instance, you can have a blog post that uses a layout:

```md
---
layout: _post_layout.slime
title: My blog post
---

This is a blog post.
```

And that layout can use another layout:

```slime
---
layout: _layout.slime
---

h1 = @title
main = @children
```

Which may look something like this:

```slime
html
  body
    div = @children
```

This allows you to cascade down and combine any templating language.

## Collections

Collections allow you to group file using a `tags` property:

```
---
tags: post
title: A blog post
---
```

This file will be assigned to the collection `post`. Every file that
specifies the `post` tag will be listed in the `post` collection. You can
then iterate over this list by accessing the `collections` variable:

```slime
ul
  = Enum.map Map.get(collections, "post", []), fn x ->
    li
      = link x[:title], to: x[:permalink]
```

Collections are automatically updated when the files change. Files that
use a collection will also be compiled whenever a file in a collection
changes.
