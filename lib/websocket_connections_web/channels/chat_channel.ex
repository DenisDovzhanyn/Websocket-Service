defmodule WebsocketConnectionsWeb.ChatChannel do
  alias WebsocketConnections.Messages.Message
  alias WebsocketConnections.Messages
  alias WebsocketConnections.UserChat
  alias WebsocketConnections.Chats
  use Phoenix.Channel
  require Logger

  def join("chat:" <> chat_id, _params, socket) do
    case Chats.get_chat_by_user_and_chat_id(%{"user_id" => socket.assigns["user_id"], "chat_id" => chat_id}) do
      %UserChat{} ->
        Logger.info("connected on chat #{chat_id}")
        {:ok, assign(socket, "chat_id", chat_id)}

      _ -> {:error, %{"reason" => "unauthorized"}}
    end
  end

  def handle_in("new_msg", %{"content" => content}, socket) do
    message = %{"content" => content, "user_id" => socket.assigns["user_id"], "chat_id" => socket.assigns["chat_id"]}

    {channel, queue} = WebsocketConnectionsWeb.RabbitMq.get_channel()

    case AMQP.Basic.publish(channel, "", queue, Jason.encode!(message)) do
      :ok ->
        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to publish message: #{inspect(reason)}")
        {:reply, {:error, %{"error" => "Message not sent"}}, socket}
    end
  end

  # maybe instead of storing a list of users and chats they are connected to, we just store a ets table of users that are online?

  def handle_in("request_key", _, socket) do
      request = %{"chat_id" => socket.assigns["chat_id"], "recipient" => socket.assigns["user_id"]}

      {channel, queue} = WebsocketConnectionsWeb.RabbitMq.get_channel()

      case AMQP.Basic.publish(channel, "", queue, Jason.encode!(request)) do
        :ok ->
          {:noreply, socket}

        {:error, reason} ->
          Logger.error("Failed to request key #{inspect(reason)}")
          {:reply, {:error, %{"error" => "Key request not sent"}}, socket}
      end
  end

  # this is an initial call that the client will make to fetch all keys waiting if any
  #def handle_in("fetch_keys", _payload, socket) do
    #keys = OfflineKeyQueue.get_keys(socket.assigns["user_id"])

    #if Kernel.length(keys) >= 1 do
    #  push(socket, "new_key", %{"keys" => keys})
    #  OfflineKeyQueue.remove_keys(socket.assigns["user_id"])
    #end

    #{:noreply, socket}
  #end
end
