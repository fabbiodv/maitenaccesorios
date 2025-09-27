# Multi-stage Dockerfile for Medusa

# === DEVELOPMENT STAGE ===
FROM node:20-alpine AS development

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies
RUN npm ci --legacy-peer-deps

# Copy source code
COPY . .

# Expose port
EXPOSE 9000

# Use dumb-init and start script
ENTRYPOINT ["dumb-init", "--"]
CMD ["./start.sh"]

# === BUILD STAGE ===
FROM node:20-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci --legacy-peer-deps && npm cache clean --force

# Copy source code
COPY . .

# Build the application with increased memory limit (optimized for 2GB VPS)
RUN NODE_OPTIONS="--max-old-space-size=1536" npm run build

# === PRODUCTION STAGE ===
FROM node:20-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    && addgroup -g 1001 -S nodejs \
    && adduser -S medusa -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --legacy-peer-deps --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=medusa:nodejs /app/dist ./dist
COPY --from=builder --chown=medusa:nodejs /app/src ./src
COPY --from=builder --chown=medusa:nodejs /app/medusa-config.ts ./
COPY --from=builder --chown=medusa:nodejs /app/start.sh ./
COPY --from=builder --chown=medusa:nodejs /app/tsconfig.json ./

# Make start script executable
RUN chmod +x start.sh

# Switch to non-root user
USER medusa

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

# Expose port
EXPOSE 9000

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["./start.sh"]