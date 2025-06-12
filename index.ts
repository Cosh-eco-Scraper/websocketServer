// Add this line at the very top to load environment variables from .env
import 'dotenv/config';

import { WebSocketServer, WebSocket } from 'ws';
import RabbitMQMiddleware from './middlewares/rabbitMQ.js';

// Add some logs for debugging startup
console.log("Application starting up...");
console.log(`Attempting to use WS_PORT: ${process.env.WS_PORT}`);
console.log(`Attempting to connect to RabbitMQ using URL: ${process.env.RABBIT_CONNECTION_URL ? 'set' : 'NOT SET'}`); // Check if RabbitMQ URL is set

const PORT = process.env.WS_PORT || 3002;r
const wss = new WebSocketServer({ port: Number(PORT) });

const clients = new Set<WebSocket>();

wss.on('connection', (ws) => {
    clients.add(ws);
    ws.on('close', () => clients.delete(ws));
    console.log("New WebSocket client connected.");
});

function broadcastToClients(message: string) {
    for (const client of clients) {
        if (client.readyState === client.OPEN) {
            client.send(message);
        }
    }
}

// Add a try-catch around the RabbitMQ initialization if possible,
// especially if RabbitMQMiddleware itself doesn't handle fatal connection errors.
try {
    RabbitMQMiddleware.receiveMessages((msg: string) => {
        console.log("Received message from RabbitMQ:", msg);
        broadcastToClients(msg);
    });
    console.log("RabbitMQ message reception initialized.");
} catch (error) {
    console.error("ERROR: Failed to initialize RabbitMQ message reception:", error);
    process.exit(1); // Exit if RabbitMQ setup is critical
}


console.log(`WebSocket server running on port ${PORT}`);
console.log("Application fully started and listening.");

// Add generic error handlers for robustness
process.on('uncaughtException', (err) => {
  console.error('Unhandled exception caught by process:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});
