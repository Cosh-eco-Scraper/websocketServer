# Use a smaller, production-ready Node.js image for the build stage
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

COPY package.json package-lock.json ./

# Install all dependencies (dev and prod) for the build process
# We need dev dependencies like 'typescript' here.
RUN npm install

# --- ADD THIS LINE HERE ---
# Ensure executables in node_modules/.bin have execute permissions
RUN chmod +x ./node_modules/.bin/*

# Copy the rest of the application code to the container.
COPY . .

# Run your build command. This will compile your TypeScript files into JavaScript
# and place them in the 'dist' directory, as specified in your package.json.
RUN npm run build

# --- Production Stage ---
# Use the same small Node.js image for the final production image
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json for production dependency installation
COPY package.json package-lock.json ./

# Install production dependencies only. This creates the node_modules directory
# for the final image, which is smaller.
RUN npm install --production

# If you have a build step (e.g., Babel, TypeScript), copy the compiled output:
COPY --from=build /app/dist ./dist

# Expose the port your WebSocket server listens on
EXPOSE 3002

# Set the Node.js environment variable to production
ENV NODE_ENV=production

# Command to start your application in production.
# This typically runs a 'start' script defined in your package.json.
CMD ["npm", "start"]
