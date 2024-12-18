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

  def send_request_to_user(conn, request) do
    chat_id = request["request"]["chat_id"]
    case WebsocketConnectionsWeb.Endpoint.broadcast("chat:#{chat_id}", "request_key", request) do
      :ok ->
        put_status(conn, :ok)
        |> json("request sent")

      {:error, reason} ->
        put_status(conn, :error)
        |> json(%{errors: reason})
    end
  end


end
