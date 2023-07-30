defmodule GitHue.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :git_hue,
      version: "0.1.0",
      elixir: "~> 1.15",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hue_sdk, "~> 0.1.0"},
      {:req, "~> 0.3.0"}
    ]
  end
end
