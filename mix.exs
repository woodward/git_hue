defmodule GitHue.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :git_hue,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GitHue.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hue_sdk, "~> 0.1.0"},
      {:patch, "~> 0.12.0", only: [:test]},
      {:req, "~> 0.3.0"}
    ]
  end
end
