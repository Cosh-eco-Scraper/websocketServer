import amqp from 'amqplib';
import 'dotenv/config';

export const variables = {
  queue: 'scraper_updates',
  connectionUrl: process.env.RABBIT_CONNECTION_URL || ''
};

export async function receiveMessages(onMessage?: (msg: string) => void) {
  try {
    const connection = await amqp.connect(variables.connectionUrl);
    const channel = await connection.createChannel();

    await channel.assertQueue(variables.queue, { durable: true });

    await channel.consume(
      variables.queue,
      (msg) => {
        if (msg !== null) {
          const messageContent = msg.content.toString();
          if (onMessage) {
            onMessage(messageContent);
          }
          channel.ack(msg);
        }
      },
      { noAck: false },
    );
  } catch (error) {
    console.error('Error receiving messages:', error);
  }
}

const RabbitMQMiddleware = {
  variables,
  receiveMessages,
};

export default RabbitMQMiddleware;
