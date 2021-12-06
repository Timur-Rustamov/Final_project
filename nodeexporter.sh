#!/bin/bash
sudo useradd -rs /bin/false node_exporter
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar -xvf node_exporter-0.18.1.linux-amd64.tar.gz
sudo mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
sudo cp ~/node_exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sleep 5
sudo systemctl enable node_exporter