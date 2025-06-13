# websocketServer

A Node.js WebSocket server that receives messages from RabbitMQ and routes them to connected WebSocket clients.

## Authors:

- Liam Omen
- Rafik Anamse
- Matteo Boulanger
- Aaron Abbey

## Features

- WebSocket server using [`ws`](https://www.npmjs.com/package/ws)
- Receives messages from RabbitMQ via [`amqplib`](https://www.npmjs.com/package/amqplib)
- Routes messages to specific clients based on `clientId`
- Environment variable configuration via `.env`
- TypeScript support

## Project Structure

```
.
├── .env
├── index.ts
├── middlewares/
│   └── rabbitMQ.ts
├── package.json
├── tsconfig.json
└── README.md
```

## Getting Started

### Prerequisites

- Node.js 20+
- RabbitMQ instance (local or cloud)
- Docker (optional)

### Installation

1. Clone the repository and install dependencies:

   ```sh
   npm install
   ```

2. Create a `.env` file in the root directory:

   ```
   RABBIT_CONNECTION_URL=your_rabbitmq_url
   WS_PORT=3002
   ```

### Running in Development

```sh
npm run dev
```

### Building and Running in Production

```sh
npm run build
npm start
```

### Using Docker

Build and run the container:

```sh
docker build -t websocketserver .
docker run --env-file .env -p 3002:3002 websocketserver
```

## WebSocket Protocol

- **Client registration:**  
  After connecting, clients must send a JSON message to register:

  ```json
  { "type": "register", "clientId": "your_client_id" }
  ```

- **Message routing:**  
  The server routes messages from RabbitMQ with the following format:

  ```json
  { "target": "client_id", "content": "your message here" }
  ```

  The client with the matching `clientId` will receive the `content` as a plain string.

## Environment Variables

- `RABBIT_CONNECTION_URL`: RabbitMQ connection string
- `WS_PORT`: Port for the WebSocket server (default: 3002)
