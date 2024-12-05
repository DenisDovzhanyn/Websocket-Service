defmodule WebsocketConnectionsWeb.RabbitMq do
  use GenServer
  alias AMQP.{Connection, Channel, Exchange}
  require Logger
  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, channel} = Channel.open(conn)
    :ok = Exchange.declare(channel, "message_exchange", :fanout, durable: true)
    
    Logger.info("rabbitmq genserver started")
    {:ok, %{conn: conn, channel: channel}}
  end

  def get_channel do
    GenServer.call(__MODULE__, :get_channel)
  end

  @impl true
  def handle_call(:get_channel, _from, %{channel: channel} = state) do
    {:reply, channel, state}
  end

  @impl true
  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
  end
end
