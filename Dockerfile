# --- Build Stage ---
# Uses a Node.js image with build tools. Alpine is chosen for its smaller size.
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker's build cache.
# This way, if only source code changes, npm install won't re-run.
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies like TypeScript and ts-node)
# These are necessary for the 'npm run build' step.
RUN npm install

# Copy the rest of your application code (TypeScript source files, etc.)
COPY . .

# Run your build command. This will compile your TypeScript files into JavaScript
# and place them in the 'dist' directory, as specified in your package.json.
RUN npm run build

# Prune development dependencies from node_modules.
# This makes the node_modules directory much smaller for the final production image.
RUN npm prune --production

# --- Production Stage ---
# Uses a lean Node.js runtime image for the final production environment.
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

# Copy only the absolutely essential files from the 'build' stage to the 'production' stage:
# 1. The pruned node_modules: Contains only production dependencies.
# 2. package.json: Needed for 'npm start' command.
# 3. The compiled 'dist' directory: Your ready-to-run JavaScript code.
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/dist ./dist

# Expose the port your WebSocket server listens on.
EXPOSE 3002

# Set the Node.js environment variable to production.
# This enables optimizations and production-specific behavior in many libraries.
ENV NODE_ENV=production

# Command to start your application in production.
# This assumes your package.json has a 'start' script like "start": "node dist/index.js".
CMD ["npm", "start"]
