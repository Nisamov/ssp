#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

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

# Ruta del script de servicio Python
PYTHON_SCRIPT_PATH="/usr/local/sbin/ssp/py_service/ssp.service.py"

# Verificar que el archivo de script de Python exista
if [ ! -f "$PYTHON_SCRIPT_PATH" ]; then
    echo "Error: El archivo $PYTHON_SCRIPT_PATH no existe."
    exit 1
fi

# Asegurarse de que el script de Python sea ejecutable
sudo chmod +x "$PYTHON_SCRIPT_PATH"

# Generar el archivo ssp.service
sudo bash -c "cat <<EOL > /usr/lib/systemd/system/ssp.service
[Unit]
Description=Secure Service Protocol
After=local-fs.target

[Service]
ExecStart=/usr/bin/python3 $PYTHON_SCRIPT_PATH
Restart=always
User=$USER
Group=$GROUP
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

# Mostrar el estado del servicio
$status_daemon