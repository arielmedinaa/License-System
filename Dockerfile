FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p app/api/endpoints app/core app/crud app/db app/models app/schemas

RUN touch app/__init__.py \
    app/api/__init__.py \
    app/api/endpoints/__init__.py \
    app/core/__init__.py \
    app/crud/__init__.py \
    app/db/__init__.py \
    app/models/__init__.py \
    app/schemas/__init__.py

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]