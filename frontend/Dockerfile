# ==========================================
# Multi-stage Dockerfile for React Frontend
# ==========================================

# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Clean install dependencies
RUN npm ci

# Accept build arguments for environment configuration
ARG VITE_API_URL=http://localhost:8000/api/hello/
ENV VITE_API_URL=${VITE_API_URL}

# Copy frontend source code
COPY . .

# Build production assets with TypeScript compilation & Vite
RUN npm run build

# Stage 2: Production runtime stage
FROM nginx:alpine AS runtime

# Install curl for container healthcheck
RUN apk add --no-cache curl

# Security: Create non-root system user and group
RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

# Remove default nginx html
RUN rm -rf /usr/share/nginx/html/*

# Copy built static assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Prepare directories and PID file for non-root execution
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /usr/share/nginx/html \
                              /var/cache/nginx \
                              /var/log/nginx \
                              /etc/nginx/conf.d \
                              /var/run/nginx.pid

# Switch to non-root user
USER appuser

EXPOSE 80

# Container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/healthz || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
