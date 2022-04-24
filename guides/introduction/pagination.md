# Pagination

Pagination allows you to create multiple files from a single template.
For instance, to create two pages with 2 items each, you can do something like this:

```
pagination:
  data: [1, 2, 3, 4]
  size: 2
---

h1 Page #{@pagination.page_nr}

ul
  = Enum.map @pagination.items, fn item ->
    li = item
```

`:data` must be a valid Elixir list, and you can reference data available in the frontmatter.
For instance, the following example would generate the same as above:

```
items: [1, 2, 3, 4, 5, 6]
pagination:
  data: [1, 2, 3, 4] |> Enum.take(4)
  size: 2
---

h1 Page #{@pagination.page_nr}

ul
  = Enum.map @pagination.items, fn item ->
    li = item
```

If your template is in `books/reviews.md`, the output files will be `books/reviews/1` and `books/reviews/2`.
You can change this behaviour using a permalink. See `Still.Preprocessor.OutputPath` for more information.

See `Still.Preprocessor.Pagination` for more information.
