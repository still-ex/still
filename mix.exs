defmodule Still.MixProject do
  use Mix.Project

  def project do
    [
      app: :still,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: ["lib"] ++ elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Still.Application, []},
      env: [
        reload_msg: "reload",
        server: false
      ]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.8"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:markdown, github: "subvisual/markdown", ref: "b5d1832"},
      {:file_system, "~> 0.2.8"},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:slime, "~> 1.2"},
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
end
