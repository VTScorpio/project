#!/bin/bash

# Intervalul de rulare (default: 5 secunde)
INTERVAL=${MONITOR_INTERVAL:-5}
LOG_FILE="/backup/system-state.log"

while true; do
  {
    echo "Timp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "CPU: $(top -bn1 | grep '%Cpu' | awk '{print $2 + $4}')%"
    echo "RAM: $(free -m | awk '/Mem:/ {printf("%.2f%%", $3/$2*100)}')"
    echo "Active Processes: $(ps ax | wc -l)"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
  } > "$LOG_FILE"
  sleep "$INTERVAL"
done