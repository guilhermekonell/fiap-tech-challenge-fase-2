FROM python:3.10-slim AS builder
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1

RUN useradd --create-home --uid 10001 app
WORKDIR /app

COPY --from=builder /install /usr/local
COPY app.py .

USER app
EXPOSE 8005
CMD ["gunicorn", "--bind", "0.0.0.0:8005", "app:app"]
