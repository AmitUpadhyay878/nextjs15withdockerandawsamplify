# Stage 1: Install dependencies and build the app
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./

# Use build arguments to specify the environment
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Install only the necessary dependencies based on the environment
RUN if [ "$NODE_ENV" = "production" ]; then npm ci --only=production; else npm install; fi

# Copy application files
COPY . .

# Build the application for production or development
RUN if [ "$NODE_ENV" = "production" ]; then npm run build; else echo "Skipping build for non-production environment"; fi



# Stage 2: Create the runtime image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Use build arguments to specify the environment
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Copy necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# For production, include only the built application
COPY --from=builder /app/.next ./.next

# Expose the default port
EXPOSE 3000

# Run the application based on the environment
CMD if [ "$NODE_ENV" = "production" ]; then npm run start; else npm run dev; fi
