#!/bin/bash
# Option: System (bare-metal) + Prometheus + Node Exporter + Grafana + systemd
set -e
echo "Starting SRE observability stack deployment..."
sudo apt-get update -y && sudo apt-get install -y curl tar

# PROMETHEUS
PROM_VER="2.52.0"
curl -LO "https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz"
tar -xzf prometheus-*.tar.gz && cd prometheus-*
sudo useradd --no-create-home --shell /bin/false prometheus 2>/dev/null || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp prometheus promtool /usr/local/bin/
sudo cp -r consoles console_libraries /etc/prometheus/
sudo cp ../prometheus/prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
cd ..

# NODE EXPORTER
EXP_VER="1.8.0"
curl -LO "https://github.com/prometheus/node_exporter/releases/download/v${EXP_VER}/node_exporter-${EXP_VER}.linux-amd64.tar.gz"
tar -xzf node_exporter-*.tar.gz
sudo cp node_exporter-*/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null || true

# GRAFANA
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update -y && sudo apt-get install -y grafana

# SYSTEMD SERVICES
sudo cp prometheus/prometheus.service /etc/systemd/system/
sudo cp node-exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus node-exporter grafana-server
echo "Done! Prometheus: :9090 | Node Exporter: :9100 | Grafana: :3000"