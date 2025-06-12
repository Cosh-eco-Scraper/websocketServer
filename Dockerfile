# Use a smaller, production-ready Node.js image for the build stage
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker caching
COPY package.json package-lock.json ./

# Install all dependencies (dev and prod) for the build process
# This creates the node_modules folder inside the container
RUN npm install

# Copy the rest of the application code *after* npm install and dependency creation.
# This ensures that your application code is present for the build.
COPY . .

# --- CRITICAL STEPS FOR DIAGNOSIS AND FIX ---
# Verify the permissions of tsc *before* attempting to run it
RUN ls -l ./node_modules/.bin/tsc || echo "tsc not found or ls failed"

# Explicitly ensure execute permissions for all binaries in node_modules/.bin
# This should run after all files are copied and node_modules is populated.
RUN find ./node_modules/.bin -maxdepth 1 -type f -exec chmod +x {} \;

# Run your build command. This will compile your TypeScript files.
RUN npm run build

# --- Production Stage ---
# Use the same small Node.js image for the final production image
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json for production dependency installation
COPY package.json package-lock.json ./

# Install production dependencies only for the final, smaller image
RUN npm install --production

# Copy the compiled output from the 'build' stage
COPY --from=build /app/dist ./dist

# Expose the port your WebSocket server listens on
EXPOSE 3002

# Set the Node.js environment variable to production
ENV NODE_ENV=production

# Command to start your application in production.
CMD ["npm", "start"]
