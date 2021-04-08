# Getting Started

Still is a simple static site generator for pragmatic developers. It's a modern tool that doesn't magically solve every single problem, but also doesn't create any new ones. It's a modern and sane experience, designed to be composable, easy to use and to grow in complexity with your needs and abilities.

🚧 _This documentation is still incomplete, but we built [the landing page](https://github.com/subvisual/still/tree/master/priv/site) with Still to showcase some of its features. Have a look there if you can't find what you're looking for here._

## Quick start

Still is in early active development. It requires at least Elixir 1.10.4 and Erlang 23.0.3. It may work with previous versions, but these are the versions we are using at the moment.

To bootstrap a new site, run the following commands:

```bash
mix archive.install hex still_new
mix still.new mysite
```

This will create an Elixir project in the folder _mysite_. You'll find an `index.slime` file inside `priv/site`.

Run `cd mysite` and then you can just run `mix still.dev` to start the development server. Then open [http://localhost:3000](http://localhost:3000) in your web browser to see the new website.

## Installation

Still can be used by itself or as part of another project.

### For new projects

Run `mix archive.install hex still_new` to install the archive on your system.

Afterwards, create a site by running `mix still.new my_site`. That's it!

### Adding to an existing project

Add `still` as a dependency in `mix.exs`:

```elixir
def deps do
  [
    {:still, "~> 0.5.0"}
  ]
end
```

Copy the configs from [here](https://github.com/still-ex/still/tree/master/installer/priv/templates/config) to your project.

Finally, create a file `index.slime` in the input folder.

## Development

Run `mix still.dev` to start the development server. Then your website will be available in [http://localhost:3000](http://localhost:3000/).

Still is watching your file system for changes and it refreshes the browser when necessary. If there are any errors building the website, they will show up on the browser, along with the stack trace and the context where the error happen.

If you run `iex -S mix still.dev` you'll get an interactive shell where you can test things quickly, such as API calls.

## Production

Run `mix still.compile` to compile the site to the output folder, which is `_site` by default. See the [source code for the Github Action that deploys the landing page](https://github.com/subvisual/still/blob/master/.github/workflows/site.yml) for more information on how to set up automatic deploys.
