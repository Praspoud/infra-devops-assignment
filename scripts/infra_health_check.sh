#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/infra_health.log"
APP_CONTAINER="backend_app"
DISK_THRESHOLD=85

log_alert() {
    local msg="$1"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\033[0;31m[WARNING]\033[0m $msg"
    echo "$timestamp [WARNING] $msg" | sudo tee -a "$LOG_FILE" > /dev/null
}

# 1. Resource Utilization Metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
RAM_USAGE=$(free -m | awk '/Mem:/ { printf("%.2f"), $3/$2 * 100 }')
ROOT_DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

echo "=== System Health Metrics ==="
echo "CPU Usage:      ${CPU_USAGE}%"
echo "RAM Usage:      ${RAM_USAGE}%"
echo "Root Disk Usage: ${ROOT_DISK_USAGE}%"

# 2. Check Docker Daemon
if ! systemctl is-active --quiet docker; then
    log_alert "Docker daemon is not running."
else
    echo "Docker Daemon:  Running"
fi

# 3. Check App Container Status
if [ "$(docker inspect -f '{{.State.Running}}' "$APP_CONTAINER" 2>/dev/null || echo "false")" != "true" ]; then
    log_alert "Application container '$APP_CONTAINER' is stopped or missing."
else
    echo "App Container:  Running ($APP_CONTAINER)"
fi

# 4. Check Disk Threshold
if [ "$ROOT_DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_alert "Root disk usage is at ${ROOT_DISK_USAGE}%, exceeding threshold of ${DISK_THRESHOLD}%."
fi
