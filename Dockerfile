FROM python:3.12-slim

# libgomp is needed by XGBoost at runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Run as a non-root user; the app writes history.json into its own folder,
# so that folder must be owned by this user.
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /home/user/app

COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY --chown=user . .

# Render sets $PORT at runtime (default 10000); this is the fallback.
ENV PORT=10000
EXPOSE 10000
# One worker: each worker loads its own copy of the models, and the free
# tier only has 512 MB of RAM.
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT} --workers 1"]
