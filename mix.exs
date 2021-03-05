defmodule Still.MixProject do
  use Mix.Project

  @version "0.3.1"

  def project do
    [
      app: :still,
      description: "A modern static site generator for the Elixir community",
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: ["lib"] ++ elixirc_paths(Mix.env()),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      name: "Still",
      source_url: "https://github.com/still-ex/still",
      homepage_url: "https://stillstatic.io",
      docs: docs(),
      xref: [exclude: [IEx]]
    ]
  end

  defp docs do
    [
      main: "getting_started",
      extras: [
        "guides/introduction/getting_started.md",
        "guides/introduction/templates.md",
        "guides/introduction/configuration.md",
        "guides/advanced/preprocessors.md"
      ],
      nest_modules_by_prefix: [
        Still.Preprocessor,
        Still.Compiler,
        Still.Web
      ],
      groups_for_extras: [
        Introduction: Path.wildcard("guides/introduction/*.md"),
        Advanced: Path.wildcard("guides/advanced/*.md")
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Still.Application, []},
      env: [
        server: false,
        profiler: false
      ]
    ]
  end

  defp deps do
    [
      {:cachex, "~> 3.3"},
      {:cowboy, "~> 2.8"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:ex_image_info, "~> 0.2.4"},
      {:file_system, "~> 0.2.10"},
      {:floki, "~> 0.29.0"},
      {:jason, "~> 1.2"},
      {:markdown, "~> 0.1.1", hex: :still_markdown},
      {:mock, "~> 0.3.0", only: :test},
      {:mogrify, "~> 0.8.0"},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:slime, "~> 1.2"},
      {:timex, "~> 3.5"},
      {:yaml_elixir, "~> 2.4"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp elixirc_paths(:test) do
    ["test/support"]
  end

  defp elixirc_paths(_), do: []

  defp package() do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/still-ex/still"},
      files: [
        "LICENSE",
        "mix*",
        "lib/*",
        "priv/still/*",
        "installer/lib/*",
        "installer/mix*",
        "installer/priv"
      ]
    ]
  end
end
