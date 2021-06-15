# Template

We call template to almost any file in the input folder. Templates
are transformed, and combined, to create the website.

## Template Helpers

In templates, you can usually write Elixir, which allows you to extend
your site with abstractions to generate CSS or make API calls. Still comes
with some functions out of the box to help you build your website. We call
these template helpers.

### Including other files or templates

Use the `include/3` function to import the contents of another file. For
instance, the following template includes the file `_includes/head.slime`:

```slim
html
  head
    = include @env, "_includes/head.slime"
  body
    = children
```

Behind the scenes, Still will render `head.slime` to HTML and replace the
function call with its contents.

### Linking to other files

The `link/3` function creates HTML hyperlinks. It takes care of specifying
the `rel` and `target` when necessary, and it supports both full URLs or
paths relative to the input folder. **You should always use the link
function to create hyperlinks between files, otherwise deploys to
subpaths will not work.** For instance:

```slim
= link @env, "Home", to: "/"
= link @env, "Blog", to: "https://example.org"
```

### Including images

Image support is still (get it?) rudimentary: it can only generate images of
different sizes. By default, it relies
on [ImageMagick][imagemagick], but if you install [`still_imageflow`][still_imageflow]
as a dependency it will use [imageflow][imageflow]. The reason we do not use imageflow by default is that it requires Rust. If you want to use ImageMagick, you
also need to have it installed in your system.

To insert an image use the function `responsive_image/2`. The first
argument is the image's path and the second a keyword list. To transform
the image we only care about the `:sizes` key, everything else will be
rendered as an attribute on the generated `img` tag.

The `:sizes` key is optional and by default we take the image's width to generate
3 smaller images. If you specify an array of integers, it will use that
instead.

A responsive image can be generated like this:

```eex
<%= responsive_image("example.jpg") %>
```

```slime
= responsive_image("cover.jpg", class: "cover")
```

and it will include the proper `src` and `srcset` attributes to use the different images at the right time.

[imagemagick]: https://imagemagick.org/
[imageflow]: https://github.com/imazen/imageflow
[imagemagic-cli-option]: https://imagemagick.org/script/command-line-options.php
[imageflow-docs]: https://docs.imageflow.io/
[still_imageflow]: https://github.com/still-ex/still_imageflow

### Custom helpers

You can call any module from the templates (`Enum.reverse(list)` or `MyHelpers.func()`). However, if you want to write custom template helpers, you can add them to the configuration and their functions will be imported to the templates using `import Your.Module`.

```elixir
config :still,
  template_helpers: [Your.Module]
```

## Configuration

Most template files allow for a [YAML Front Matter](https://jekyllrb.com/docs/front-matter/) block to change their configuration.

If you add your own template language, you can support this by ensuring the file's preprocessor pipeline includes `Still.Preprocessor.Frontmatter`.

### Permalink

Setting the `permalink` option allows you to override the output path of a file. For instance, by default `blog/post_1/index.md` would generate `blog/post_1/index.html`, but you can change it to `blog/announcment.html` like this:

```slime
---
permalink: `blog/announcment.html`
---

# Post 1 - Announcement
```

### Layouts

Layouts are templates that wrap other content. To use a layout, set the
`layout` key in front matter. For instance:

```slime
---
layout: _layout.slime
---

h1 About Page
```

This will look for a `_layout.slime` in your input folder.

The layout file must render the `@children` variable:

```slime
doctype html
html
  body
    = @children
```

Notice that `_layout.slime` starts with an underscore. **This is necessary
since we don't want to compile the layout file by itself**. Any file
starting with an underscore isn't compiled to the output, but can still be
imported by other files.

#### More Examples

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

#### Layout Chaining

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

### Collections

Collections allow you to group file using a `tags` property:

```
---
tags:
  - post
title: A blog post
---
```

This file will be assigned to the collection `post`. Every file that
specifies the `post` tag will be listed in the `post` collection. You can
then iterate over this list using the `get_collections/2` function:

```slime
ul
  = Enum.map get_collections(@env, "post"), fn x ->
    li
      = link x[:title], to: x[:permalink]
```

Collections are automatically updated when the files change. Files that
use a collection will also be compiled whenever a file in a collection
changes.

Files that do not generate an output file, such as file that start with an underscore like `_layout.slime`, are never added to collections. We are still considering whether we want to keep this behavior or not.
