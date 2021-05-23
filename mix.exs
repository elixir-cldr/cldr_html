defmodule Cldr.Html.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :cldr_html,
      version: @version,
      elixir: "~> 1.8",
      compilers: Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Cldr HTML",
      description: description(),
      source_url: "https://github.com/elixir-cldr/cldr_html",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(ex_money)a
      ],
    ]
  end

  defp description do
    """
    HTML helper functions for the Common Locale Data
    Repository (CLDR).
    """
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      logo: "logo.png",
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-cldr/cldr_html",
      "Readme" => "https://github.com/elixir-cldr/cldr_html/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/elixir-cldr/cldr_html/blob/v#{@version}/CHANGELOG.md"
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_cldr, "~> 2.22"},
      {:phoenix_html, "~> 1.2 or ~> 2.0"},
      {:ex_cldr_currencies, "~> 2.8", optional: true},
      {:ex_cldr_territories, "~> 2.2", optional: true},
      {:ex_money, "~> 5.0", optional: true},
      {:ex_cldr_units, "~> 3.5", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:poison, "~> 2.1 or ~> 3.0 or ~> 4.0", optional: true},
      {:ex_doc, "~> 0.18", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "src", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "bench"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
