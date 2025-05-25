#!/bin/bash

while true; do
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEM_USED=$(free -m | awk '/Mem/ {printf "%.2f", $3 / 1024}')
    MEM_TOTAL=$(free -m | awk '/Mem/ {printf "%.2f", $2 / 1024}')
    DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -n 1)

    echo "CPU: $CPU% | RAM: $MEM_USED/$MEM_TOTAL GB | Disk: $DISK_USED/$DISK_TOTAL | IP: ${IP:-No IP} | $(date +"%Y-%m-%d %H:%M:%S")"
    sleep 1
done
