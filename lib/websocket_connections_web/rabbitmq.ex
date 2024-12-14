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

    Logger.info("rabbitmq genserver started")
    {:ok, %{queue: queue}} = AMQP.Queue.declare(channel, "worker_queue", durable: true)

    {:ok, %{conn: conn, channel: channel, queue: queue}}
  end

  def get_channel do
    GenServer.call(__MODULE__, :get_channel)
  end

  @impl true
  def handle_call(:get_channel, _from, %{channel: channel, queue: queue} = state) do
    {:reply, {channel, queue}, state}
  end

  @impl true
  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
  end
end
