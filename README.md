# Monitoring Stack Demo

A production-ready local monitoring stack built with industry-standard open-source tools. Spin up a fully integrated observability environment — metrics, logs, and dashboards — with a single command.

---

## Stack Overview

| Component | Role |
|---|---|
| **Sample Python App** | Web application exposing metrics endpoints and structured logs |
| **Prometheus** | Metrics collection, storage, and alerting |
| **Grafana** | Visualization dashboards for metrics and logs |
| **Loki** | Log aggregation and query engine |
| **Promtail** | Log shipping agent for app and system logs |
| **Node Exporter** | Host-level system metrics (CPU, memory, disk, network) |
| **cAdvisor** | Per-container resource usage and performance metrics |

---

## Features

- **Unified observability** — correlate metrics and logs in a single Grafana interface
- **Preconfigured dashboards** — get actionable insights immediately after startup
- **Centralized logging** — aggregate and query logs across all services with Loki
- **Container & host metrics** — full visibility into system and Docker resource usage
- **One-command deployment** — Docker Compose setup requires no manual configuration

---

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) (tested with Docker Desktop)
- Docker Compose (included with Docker Desktop)

> **Note:** Ensure Docker Desktop is allocated sufficient resources. A minimum of **2 CPUs** and **4 GB of memory** is recommended.

---

## Getting Started

**1. Clone the repository**

```bash
git clone https://github.com/yourusername/monitoring-stack-demo.git
cd monitoring-stack-demo
```

**2. Build and start all services**

```bash
docker-compose up --build -d
```

**3. Access the interfaces**

| Service | URL | Credentials |
|---|---|---|
| Grafana | http://localhost:3000 | `admin` / `admin` |
| Prometheus | http://localhost:9090 | — |
| Loki (API) | http://localhost:3100 | — |

---

## Usage

- **Grafana** — Open preconfigured dashboards to explore app metrics, system performance, and aggregated logs in real time.
- **Loki** — Use LogQL in Grafana's Explore view to filter and query logs across all services.
- **Prometheus** — Run PromQL queries directly or inspect scrape targets and alert rules at `/targets`.

---

## Troubleshooting

**Containers fail to start**
- Verify volume paths and bind mounts in `docker-compose.yml` match your local directory structure.
- Ensure no port conflicts exist on `3000`, `9090`, or `3100`.

**Viewing container logs**
```bash
docker logs <container_name>
```

**Insufficient resources**
- Open Docker Desktop → Settings → Resources and increase CPU and memory allocation.

---

## License

Distributed under the [MIT License](LICENSE).

---

## Contributing

Contributions, bug reports, and feature requests are welcome. Please open an issue or submit a pull request.
