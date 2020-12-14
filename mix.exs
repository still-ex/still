defmodule Still.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :still,
      description: "A modern static site generator for the Elixir community",
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: ["lib"] ++ elixirc_paths(Mix.env()),
      package: package(),
      source_url: "https://github.com/subvisual/still",
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Still.Application, []},
      env: [
        server: false
      ]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.8"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:file_system, "~> 0.2.8"},
      {:markdown, "~> 0.1.0", hex: :still_markdown},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3.0", only: :test},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:slime, "~> 1.2"},
      {:floki, "~> 0.29.0"},
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
      links: %{"GitHub" => "https://github.com/subvisual/still"}
    ]
  end
end
