# Use a smaller, production-ready Node.js image for the build stage
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

COPY package.json package-lock.json ./

# Install all dependencies (dev and prod) for the build process
RUN npm install

# Ensure executables in node_modules/.bin have execute permissions
RUN chmod +x ./node_modules/.bin/*

# Copy the rest of the application code to the container.
COPY . .

# Run your build command. This command should be defined in your package.json
# and should output compiled files to a 'dist' directory.
RUN npm run build

# --- Production Stage ---
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --production

# Copy the compiled output from the 'build' stage
COPY --from=build /app/dist ./dist

# Expose the port your WebSocket server listens on
EXPOSE 3002

# Set the Node.js environment variable to production
ENV NODE_ENV=production

# Command to start your application in production.
CMD ["npm", "start"]
