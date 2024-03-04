defmodule GigalixirFlameExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    flame_parent = FLAME.Parent.get()

    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {FLAME.Pool, name: GigalixirFlameExample.FlameWorker, min: 0, max: 10, max_concurrency: 5, idle_shutdown_after: 20},
      GigalixirFlameExampleWeb.Telemetry,
      !flame_parent && {Cluster.Supervisor, [topologies, [name: GigalixirFlameExample.ClusterSupervisor]]},
      {Phoenix.PubSub, name: GigalixirFlameExample.PubSub},
      # Start the Finch HTTP client for sending emails
      !flame_parent && {Finch, name: GigalixirFlameExample.Finch},
      # Start a worker by calling: GigalixirFlameExample.Worker.start_link(arg)
      # {GigalixirFlameExample.Worker, arg},
      # Start to serve requests, typically the last entry
      !flame_parent && GigalixirFlameExampleWeb.Endpoint
    ]
    |> Enum.filter(& &1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GigalixirFlameExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GigalixirFlameExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
