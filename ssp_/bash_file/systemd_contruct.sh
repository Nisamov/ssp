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
cat <<EOL > /etc/systemd/system/ssp.service
[Unit]
Description=Secure System Protocol
DefaultDependencies=no
After=local-fs.target

[Service]
ExecStart=/ruta/al/tu-script.sh
Restart=always
User=$USER
Group=$GROUP

[Install]
WantedBy=default.target
EOL

# Habilitar servicio
$reload_damon
$unmask_daemon
$enable_daemon