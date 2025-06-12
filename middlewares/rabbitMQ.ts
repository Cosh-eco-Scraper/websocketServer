import amqp from 'amqplib';

export const variables = {
  queue: 'scraper_updates',
  connectionUrl: "amqps://qxpngojo:ZzIYQTgUDylWoHp_5iHbTEa4c_X3VZl1@seal.lmq.cloudamqp.com/qxpngojo",
};

export async function receiveMessages(onMessage?: (msg: string) => void) {
  try {
    const connection = await amqp.connect(process.env.RABBIT_CONNECTION_URL || variables.connectionUrl);
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
