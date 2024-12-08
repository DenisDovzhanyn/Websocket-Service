defmodule WebsocketConnections.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WebsocketConnectionsWeb.Telemetry,
      WebsocketConnections.Repo,
      {DNSCluster, query: Application.get_env(:websocket_connections, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WebsocketConnections.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WebsocketConnections.Finch},
      # Start a worker by calling: WebsocketConnections.Worker.start_link(arg)
      # {WebsocketConnections.Worker, arg},
      # Start to serve requests, typically the last entry
      WebsocketConnectionsWeb.Endpoint,
      WebsocketConnectionsWeb.RabbitMq,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebsocketConnections.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WebsocketConnectionsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
