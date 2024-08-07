#!/bin/bash

# Otorgar permisos al software



# Rutas del software
# Ruta del directorio donde se encuentra el script de instalación
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Ubicacion del servicio
service_location="/etc/systemd/system"
# Nombre del servicio
service_name="ssp.service"
# Recarga, Habilitacion y Estado del demonio
reload_damon="sudo systemctl daemon-reload"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"

# Montar, instalar y documentar
echo "$install_dir"