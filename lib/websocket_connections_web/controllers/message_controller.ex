defmodule WebsocketConnectionsWeb.MessageController do
  alias WebsocketConnectionsWeb.MessageConsumer
  use WebsocketConnectionsWeb, :controller

  # workers will directly hit this api to tell the websocket to broadcast
  def send_to_user(conn, message) do
    chat_id = message["message"]["chat_id"]
    case WebsocketConnectionsWeb.Endpoint.broadcast("chat:#{chat_id}", "new_msg", message) do
      :ok ->
        put_status(conn, :ok)
        |> json("message sent to clients")

      {:error, reason} ->
        put_status(conn, :error)
        |> json(%{errors: reason})
    end

  end
end
