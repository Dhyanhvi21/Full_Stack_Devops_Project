# ==========================================
# Multi-stage Dockerfile for Django Backend
# ==========================================

# Stage 1: Build stage (Python 3.12 required for Django 6.0+)
FROM python:3.12-slim AS builder

WORKDIR /build

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Production runtime stage
FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:${PATH}" \
    PYTHONPATH="/install/lib/python3.12/site-packages:${PYTHONPATH}"

# Install minimal runtime dependencies & curl for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Security: Create non-root system group and user
RUN addgroup --system --gid 10001 appgroup && \
    adduser --system --uid 10001 --ingroup appgroup --no-create-home appuser

# Copy installed Python packages from builder stage
COPY --from=builder /install /install

# Copy backend application source code
COPY --chown=appuser:appgroup . /app

# Switch to non-root user
USER appuser

EXPOSE 8000

# Health check endpoint verification
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/api/health/ || exit 1

# Start production WSGI server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "config.wsgi:application"]
