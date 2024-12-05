defmodule WebsocketConnectionsWeb.MessageConsumer do
  alias WebsocketConnections.Messages
  alias Postgrex.Messages
  alias WebsocketConnections.Messages.Message
  use GenServer
  require Logger
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    channel = WebsocketConnectionsWeb.RabbitMq.get_channel()

    {:ok, %{queue: queue}} = AMQP.Queue.declare(channel, "", exclusive: true)

    :ok = AMQP.Queue.bind(channel, queue, "message_exchange")

    case AMQP.Basic.consume(channel, queue, nil, no_ack: true) do
      {:ok, _binary} ->
        {:ok, %{channel: channel}}

      {:error, reason} ->
        {:stop, {:queue_consumer_error, reason}}
    end
  end

  @impl true
  def handle_info({:basic_deliver, payload, _meta}, state) do
    {:ok, message} = Jason.decode(payload)

    case WebsocketConnections.Messages.create_message(message) do
      {:ok, new_msg} ->

        chat_id = Map.get(new_msg, :chat_id)
        content = Map.get(new_msg, :content)
        user_id = Map.get(new_msg, :user_id)

        WebsocketConnectionsWeb.Endpoint.broadcast("chat:#{chat_id}", "new_msg", %{"content" => content, "user_id" => user_id})
        {:noreply, state}

      {:error, changeset} ->
        Logger.error("we got a problem in the messageconsumer handleinfo method, #{changeset}")
        {:noreply, state}
    end

  end


  @impl true
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Consumer registered with tag: #{consumer_tag}")
    {:noreply, state}
  end


end
