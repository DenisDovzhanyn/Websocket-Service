### **WebSocket Connections**


# WebSocket Connections

The WebSocket Connections service is responsible for handling real-time communication between clients and the backend. This service allows users to subscribe to their chats and ensures messages are sent and broadcasted efficiently.

## Features

- **WebSocket Connections**: Users connect to a WebSocket after authentication.
- **Chat Subscriptions**: Users subscribe to specific chats to receive messages.
- **Message Processing**:
  - Messages sent by users are placed onto a RabbitMQ message queue.
  - A worker service processes the messages and routes them back to a WebSocket Connections service for broadcasting.

## Tech Stack

- **WebSockets**: Real-time communication protocol.
- **RabbitMQ**: Message queue for handling chat messages.
- **Phoenix Framework**: WebSocket support and application server.

## Flow

1. User logs in via api to receive JWT token and then establishes a WebSocket connection via this service.
2. User subscribes to their chats via the WebSocket.
3. Messages sent by the user are:
   - Published to a RabbitMQ queue.
   - Retrieved and processed by a worker service.
   - Sent back to a WebSocket Connectoin service to be broadcasted to other connected clients.