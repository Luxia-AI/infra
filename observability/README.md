# Luxia Observability Stack

This folder contains Prometheus, Grafana, Alertmanager, Loki, Tempo, Promtail, and OpenTelemetry Collector configuration used by `docker-compose.yml`.

## Required environment variables

Set these in your root `.env` before running compose:

- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`
- `ALERT_EMAIL_TO`
- `ALERT_EMAIL_FROM`
- `ALERT_SMARTHOST` (example: `smtp.gmail.com:587`)
- `ALERT_SMTP_USER`
- `ALERT_SMTP_PASS`
- `ALERT_ENV` (`prod` or `staging`)
- `OTEL_EXPORTER_OTLP_ENDPOINT` (default: `http://otel-collector:4317`)

## Start stack

```bash
docker compose up -d --build
```

## Endpoints

- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- Alertmanager: `http://localhost:9093`
- Loki: `http://localhost:3100`
- Tempo: `http://localhost:3200`

## Notes

- Dispatcher metrics are exposed on port `9600`.
- Worker metrics are exposed at `GET /metrics` on port `9000`.
- Socket-hub metrics are exposed at `GET /metrics` on port `8000`.
- Tracing is exported over OTLP to `otel-collector` and stored in Tempo.
