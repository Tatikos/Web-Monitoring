#Monitoring Stack Demo
A complete monitoring stack demo featuring:

App: A sample Python web app exposing metrics and logs

Prometheus: Metrics collection and alerting

Grafana: Visualization dashboards for metrics and logs

Loki: Log aggregation and querying

Promtail: Log shipping from app and system

Node Exporter & cAdvisor: Host and container metrics

#Features
Collect and visualize app and system metrics

Centralized logging with Loki and Promtail

Preconfigured Grafana dashboards for quick insights

Docker Compose setup for easy local deployment

Supports real-time monitoring of your app performance and logs

#Getting Started
Prerequisites
Docker (tested with Docker Desktop)

Docker Compose

Running the Stack
Clone this repository:
```bash
git clone https://github.com/yourusername/monitoring-stack-demo.git
cd monitoring-stack-demo
```
Build and start all services:
```bash
docker-compose up --build -d
```
#Access the dashboards
Grafana: http://localhost:3000

Default user: admin

Default password: admin

Prometheus: http://localhost:9090

Loki: http://localhost:3100 (API for logs)
#Usage
Use Grafana dashboards to explore app metrics and logs.

Query logs with Loki’s powerful query language.

Monitor system metrics via Node Exporter and cAdvisor.

#Troubleshooting
If containers fail to start, check volumes and paths in docker-compose.yml

Use docker logs <container_name> to view container logs

Ensure Docker Desktop has sufficient resources (CPU, memory)

#License
MIT License — see LICENSE for details.

#Contributions
Contributions and suggestions are welcome! Feel free to open issues or pull requests.
