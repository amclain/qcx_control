Code.require_file("coverage.ignore.exs")

defmodule QcxControl.MixProject do
  use Mix.Project

  alias QcxControl.Coverage

  @app :qcx_control
  @version "0.1.0"
  @all_targets [:rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      releases: [{@app, release()}],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings.exs",
        list_unused_filters: true,
        plt_add_apps: [:mix],
        plt_file: {:no_warn, plt_file_path()}
      ],
      test_coverage: [
        tool: Coverex.Task,
        ignore_modules: Coverage.ignore_modules()
      ],
      preferred_cli_target: [
        dialyzer: :rpi0,
        run: :host,
        test: :host
      ],
      preferred_cli_env: [
        espec: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {QcxControl.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp aliases do
    [
      "coverage.show": [open("cover/modules.html")],
      "docs.show": ["docs", open("doc/index.html")],
      test: "espec --cover"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:coverex, "~> 1.5", only: :test},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:espec, "~> 1.8", only: :test},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false},
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7"},
      {:ring_logger, "~> 0.8"},
      {:toolshed, "~> 0.2"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11", targets: @all_targets},
      {:nerves_pack, "~> 0.4", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.16", runtime: false, targets: :rpi0}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["../README.md"]
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

  # Path to the dialyzer .plt file.
  defp plt_file_path do
    [Mix.Project.build_path(), "plt", "dialyxir.plt"]
    |> Path.join()
    |> Path.expand()
  end

  defp open(path) do
    fn _args ->
      System.cmd(open_command(), [path])
    end
  end

  defp open_command do
    cond do
      # Linux
      !is_nil(System.find_executable("xdg-open")) -> "xdg-open"
      # Mac
      !is_nil(System.find_executable("open")) -> "open"
      true -> raise "Could not find executable 'open' or 'xdg-open'"
    end
  end
end
