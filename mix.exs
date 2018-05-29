defmodule Cldr.Html.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :cldr_html,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers() ++ [:cldr]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_cldr, "~> 1.5"},
      {:phoenix_html, "~> 1.2 or ~> 2.0"},
      {:ex_cldr_currencies, "~> 0.1", optional: true},
      {:ex_money, "~> 2.5", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:poison, "~> 2.1 or ~> 3.0", optional: true}
    ]
  end
end
