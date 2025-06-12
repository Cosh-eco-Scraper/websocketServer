# Use the official Node.js image as the base image
FROM node:20

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Expose the WebSocket server port
EXPOSE 3002

# Set environment variables (optional, or use a .env file)
ENV NODE_ENV=production

# Start the application using the "dev" script
CMD ["npm", "run", "dev"]