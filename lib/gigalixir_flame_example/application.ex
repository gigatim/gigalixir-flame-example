defmodule GigalixirFlameExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GigalixirFlameExampleWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:gigalixir_flame_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GigalixirFlameExample.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GigalixirFlameExample.Finch},
      # Start a worker by calling: GigalixirFlameExample.Worker.start_link(arg)
      # {GigalixirFlameExample.Worker, arg},
      # Start to serve requests, typically the last entry
      GigalixirFlameExampleWeb.Endpoint
    ]

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
