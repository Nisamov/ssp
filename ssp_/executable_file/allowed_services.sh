#!/bin/bash
ALLOWED_SERVICES="/etc/ssp/permitted_services.txt"
CURRENT_SERVICES=$(ps -eo comm)

while IFS= read -r service; do
    if ! grep -q "$service" "$ALLOWED_SERVICES"; then
        echo "[SSP] Denyed ---- $service"
        systemctl stop $service
    fi
done <<< "$CURRENT_SERVICES"