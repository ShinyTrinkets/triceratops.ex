defmodule Triceratops.Mixfile do
  use Mix.Project

  def project do
    [app: :triceratops,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:porcelain, :fwatch, :bamboo, :bamboo_smtp]]
  end

  defp deps do
    [
      {:porcelain, "~> 2.0"},
      {:fwatch, "~> 0.5"},
      {:bamboo_smtp, "~> 1.2"}
    ]
  end
end
