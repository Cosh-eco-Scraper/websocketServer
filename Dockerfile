# Use a smaller, production-ready Node.js image for the build stage
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

COPY package.json package-lock.json ./

# Install all dependencies (dev and prod) for the build process
# We need dev dependencies if your build process (e.g., TypeScript compiler)
# is listed as a dev dependency.
RUN npm install

# Copy the rest of the application code to the container.
COPY . .

# --- ADD THIS LINE ---
# Run your build command. This command should be defined in your package.json
# and should output compiled files to a 'dist' directory.
RUN npm run build # Or `yarn build` if you use yarn

# --- Production Stage ---
# Use the same small Node.js image for the final production image
FROM node:20-alpine AS production

# Set the working directory inside the container
WORKDIR /app

# Only copy production node_modules. This is why we re-run npm install --production here.
# Alternatively, if your build process created a truly self-contained 'dist'
# you might not even need node_modules in the final image, but for typical
# Node.js apps, you still need them for runtime.
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
