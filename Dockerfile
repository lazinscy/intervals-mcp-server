FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python build tool and dependencies first (better layer caching)
COPY pyproject.toml .
COPY src/ src/
COPY README.md .
RUN pip install --no-cache-dir hatchling && pip install --no-cache-dir .

FROM python:3.12-slim

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY src/ src/
COPY pyproject.toml .
COPY README.md .
RUN pip install --no-cache-dir --no-deps .

# Non-root user for runtime security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/mcp')" || exit 1

USER appuser
CMD ["python", "src/intervals_mcp_server/server.py"]
