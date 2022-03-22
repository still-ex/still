# Using Data

Data can be used on a template from different sources:

1. Frontmatter.
2. `Still.Data`.
3. Modules.

Anything you declare in frontmatter becomes available in your templates:

```
---
title: Some title
---

<h1><%= @title %></h1>
```

There's also a global data loading mechanism that turns any YAML, JSON, Exs or Ex files into data that's automatically available in your templates. See `StillData` for more information.

On top of that, you can call any function from your templates:

```
<h1><%= SomeModule.some_function() %></h1>
```
