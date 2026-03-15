# Tomcat Monitoring Helm Chart

A complete Helm chart for deploying Tomcat application with full monitoring stack (Prometheus, Grafana, Loki, Alloy).

## Installation

```bash
# Install the chart
helm install tomcat-app ./tomcat-monitoring-chart

# Install with custom values
helm install tomcat-app ./tomcat-monitoring-chart -f custom-values.yaml

# Upgrade
helm upgrade tomcat-app ./tomcat-monitoring-chart

# Uninstall
helm uninstall tomcat-app
```

## Configuration

Key values you can override:

```yaml
tomcat:
  image:
    repository: your-registry/your-app
    tag: latest
  replicaCount: 2

ingress:
  host: your-domain.com

grafana:
  adminPassword: secure-password
```

## Access

- Tomcat: http://tomcat.local/
- Grafana: http://tomcat.local/grafana (admin/admin)

## Components

- Tomcat application with JMX metrics
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Alloy for telemetry collection
