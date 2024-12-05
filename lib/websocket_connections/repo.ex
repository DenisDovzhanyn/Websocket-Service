defmodule WebsocketConnections.Repo do
  use Ecto.Repo,
    otp_app: :websocket_connections,
    adapter: Ecto.Adapters.Postgres
end
