defmodule ElixirApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_app,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirApp.Application, []}
    ]
  end

  defp deps do
    []
  end

  defp releases do
    [
      elixir_app: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        steps: [:assemble, :tar]
      ]
    ]
  end
end
