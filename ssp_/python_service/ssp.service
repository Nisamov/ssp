#!/bin/bash

# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal

# Script de generación de archivo ssp.service

# Recarga, habilitación y estado del demonio
reload_daemon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"
start_daemon="sudo systemctl start ssp.service"

# Obtener el usuario y grupo actuales
USER=$(whoami)
GROUP=$(id -gn)

gcc -o /usr/local/sbin/ssp_/service/ssp.service /usr/local/sbin/ssp_/service/ssp.service.c # Compilar servicio
mv "/usr/local/sbin/ssp_/service/ssp.service.c" "/usr/local/sbin/ssp_/service/ssp.service" # Renombrar fichero

# Ruta del script de servicio Python
service_path="/usr/local/sbin/ssp_/service/ssp.service"

# Verificar que el archivo de script de Python exista
if [ ! -f "$service_path" ]; then
    echo "Error: El archivo $service_path no existe."
    exit 1
fi

# Asegurarse de que el script de Python sea ejecutable
sudo chmod +x "$service_path"

# Generar el archivo ssp.service
sudo bash -c "cat <<EOL > /usr/lib/systemd/system/ssp.service
[Unit]
Description=Secure Service Protocol
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/sbin/ssp_/service
ExecStart=/usr/local/sbin/ssp_/service/ssp.service
Restart=always
User=$USER
Group=$GROUP
Environment=PYTHONUNBUFFERED=1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL"

# Permisos para el archivo de servicio
sudo chmod 644 "/usr/lib/systemd/system/ssp.service"

# Habilitar y arrancar el servicio
$reload_daemon
$unmask_daemon
$enable_daemon
$start_daemon
