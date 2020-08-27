defmodule Extatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :extatic,
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
      mod: {Extatic.Application, []},
      env: [reload_msg: "reload"]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.8"},
      {:file_system, "~> 0.2.8"},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:slime, "~> 1.2", optional: true},
      {:yaml_elixir, "~> 2.4"},
      {:nodejs, "~> 2.0"}
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
