# Use a smaller, production-ready Node.js image for the build stage
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app


COPY package.json package-lock.json ./

# Install production dependencies only. This creates the node_modules directory.
RUN npm install --production

# Copy the rest of the application code to the container.
# This assumes your source code is in the root of your project.
COPY . .

# --- Production Stage ---
# Use the same small Node.js image for the final production image
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
# If you have a build step (e.g., Babel, TypeScript), copy the compiled output:
COPY --from=build /app/dist ./dist

# Expose the port your WebSocket server listens on
EXPOSE 3002

# Set the Node.js environment variable to production
ENV NODE_ENV=production

# Command to start your application in production.
# This typically runs a 'start' script defined in your package.json.
CMD ["npm", "start"]
