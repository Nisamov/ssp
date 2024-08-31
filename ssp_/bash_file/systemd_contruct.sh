#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

# Script de generación de archivo ssp.service

# Declaración de variables
# Recarga, habilitación y estado del demonio
reload_daemon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"
# Obtener el usuario y grupo actuales
USER=$(whoami)
GROUP=$(id -gn)

# Generar el archivo ssp.service
sudo bash -c "cat <<EOL > /usr/lib/systemd/system/ssp.service
[Unit]
Description=Secure Service Protocol
After=local-fs.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/sbin/ssp/py_service/ssp.service.py
Restart=always
User=$USER
Group=$GROUP
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL"

# Permisos
sudo chmod 644 "/usr/lib/systemd/system/ssp.service"

# Habilitar servicio
$reload_daemon
$unmask_daemon
$enable_daemon
$status_daemon