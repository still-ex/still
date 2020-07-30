defmodule Extatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :extatic,
      version: "0.1.0",
      elixir: "~> 1.10",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Extatic.Application, []}
    ]
  end

  defp deps do
    [
      {:slime, "~> 1.2"},
      {:cowboy, "~> 2.8"},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:file_system, "~> 0.2.8"},
      {:yaml_elixir, "~> 2.4"}
    ]
  end
end
