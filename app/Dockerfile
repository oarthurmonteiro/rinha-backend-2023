# Use the official Alpine based image.
FROM oven/bun:1.2.21-alpine

# Create a group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Tell docker that all future commands should run as the appuser user
USER appuser

# Set the working directory inside the container.
WORKDIR /app

# Copy the package.json and package-lock.json files.
COPY package.json bun.lock ./

# Install the dependencies.
RUN bun install

# Sets the environment.
ENV NODE_ENV=production
ENV APP_API_URL=3000

# Expose the port the app runs on.
EXPOSE $APP_API_URL

# Copy the rest of the application code.
COPY --chown=appuser:appusers . .

# Build the application.
RUN bun run build

# RUN bun run prisma-push

# Start the application.
CMD ["bun", "start"]