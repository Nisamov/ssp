#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

# Rutas del software
# Ruta del directorio donde se encuentra el script de instalación
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Ubicacion del servicio
service_location="/usr/lib/systemd/system/"
# Nombre del servicio
service_name="ssp.service"
# Recarga, Habilitacion y Estado del demonio
reload_damon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"

allowed_services="/etc/ssp/permitted_services.txt"

# Limpiar consola
clear

# Mostrar licencia
echo "By using the software, you agree to abide by the terms of the Spec.0 License."
read -p "Do you want to read the full license? [y/n]: " license_bypass
if [[ $license_bypass == "y" ]]; then
    sudo less "$install_dir/LICENSE.md"
fi

sudo mkdir "/etc/ssp"
sudo touch "$allowed_services"

# Llamar al generador de servicio
sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh"

# Montar, instalar y documentar
if [[ ! -f "$service_location/$service_name" ]]; then
    # Llamar al generador de servicio
    sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh"
    if [[ -f $service_location/$service_name ]]; then
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
    echo "File already exist, exiting..."

    read -p "Do you want to see ssp status [y/n]: " ssp_satus
    if [[ $ssp_satus == "y" ]]; then
        $status_daemon
    else
        echo "Status cancelled."
    fi

    # Existencia previa de fichero, salida 1
    exit 1
fi

# Creacion ejecutable ( para realizar acciones como la creacion y el añadido de servicios a la lista de forma automatica )

# Ruta de instalacion -- 

# Ejemplo de ejcucion:
# ssp -a -> Añadir servicio
# ssp -r -> Desinstalar servicio
# ssp -s -> Mostrar servicios permitidos (con less)