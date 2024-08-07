#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

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
if [[ -f "$install_dir/ssp_/systemd_file/$service_name" ]]; then
    sudo cp "$install_dir/ssp_/systemd_file/$service_name $service_location"
    if [[ -f $service_location/$service_name ]]; then
        # Habilitar servicio
        $reload_damon
        $enable_daemon
        read -p "Do you want to see ssp status [y/n]: " ssp_satus
        if [[ $ssp_satus == "y" ]]; then
            $status_daemon
        else
            echo "Status cancelled."
        fi
        echo "Installation complete, exiting..."
        # Servicio completado, salida 3
        exit 3
    else
        echo "Error while installing, exiting..."
        # error en la instalacion, salida 2
        exit 2
    fi
else
    echo "File does not exist, exiting..."
    # Error de existencia en ficheros o directorios, salida 1
    exit 1
fi