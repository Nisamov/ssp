#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

# Script de generacion de fichero ssp.service

# Declaracion variables
# Recarga, Habilitacion y Estado del demonio
reload_damon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"
# Obtener el usuario y grupo actuales
USER=$(whoami)
GROUP=$(id -gn)

# Generar el archivo ssp.service
cat <<EOL > /usr/lib/systemd/system/ssp.service
[Unit]
Description=Secure System Protocol
DefaultDependencies=no
After=local-fs.target

[Service]
ExecStart=/usr/local/sbin/ssp/py_service/ssp.service.py
Restart=always
User=$USER
Group=$GROUP

[Install]
WantedBy=default.target
EOL

# Permisos
sudo chmod 644 "/usr/lib/systemd/system/ssp.service"

# Habilitar servicio
$reload_damon
$unmask_daemon
$enable_daemon