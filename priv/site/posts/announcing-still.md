---
layout: "_post_layout.slime"
tag: post
title: "Still on Elixir (Announcement)"
date: 2020-10-01
---

We are proud to announce Still! Over the years, we had to build plenty of
static websites and we still do. As time passes, the tooling around building websites got
more and more complicated. It doesn't have to be. Most of the issues tools like
Gatsby solve were introduced by using overly-complex libraries and frameworks, like React and its ecosystem in the first
place! For a lot of use cases, they're great and we love using them. But a lot of times, especially when building static websites, we want the tools to be simple and easily extensible. We want minimal overhead and maximum extensibility. We want them to feel intuitive without having to scroll through pages of documentation to understand how to build them or how to add an RSS feed plugin.

Still doesn't rely on JavaScript. You can use it, and we have a package to make
it simple to integrate tools from the JS ecosystem into it, but it's not
necessary. We even built our CSS minifier!

To be honest, the CSS minifier only removes newlines, but we believe that's
enough for most people.

Now the good stuff: it's Elixir! And not just that, you can use Elixir to extend
it! You can do everything you want in Elixir and call functions from the
templates. The documentation is sparse, but have a look at the internals and
our example websites.

Finally, keep in mind that we are still figuring things out, so the APIs we
have right now will likely change. We'll try and answer any issue you open.

So why build Still instead of working on an existing solution? Because we
wanted to add some features that the other packages didn't allow for. The first
one was auto-refresh on file changes, and there's more to come. We want Still
to feel like a modern development environment. You don't have to feel like
you're building websites in 2010 just because you're not relying on the
JavaScript tooling.
