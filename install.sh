#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"
install_dir_sbin="/usr/local/sbin"

# Comandos del sistema
reload_daemon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"

# Limpiar consola
clear

# Mostrar licencia
echo "By using the software, you agree to abide by the terms of the Spec.0 License."
read -p "Do you want to read the full license? [y/n]: " license_bypass
if [[ $license_bypass == "y" ]]; then
    sudo less "$install_dir/LICENSE.md"
fi

# Crear directorio si no existe
sudo mkdir -p "/etc/ssp"

# Llamar al generador de servicio
sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh"

# Montar, instalar y documentar
if [[ ! -f "$service_location/$service_name" ]]; then
    sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh"
    if [[ -f $service_location/$service_name ]]; then
        read -p "Do you want to see ssp status [y/n]: " ssp_status
        if [[ $ssp_status == "y" ]]; then
            $status_daemon
        else
            echo "Status cancelled."
        fi
        echo "Installation complete, exiting..."
        exit 3
    else
        echo "Error while installing, exiting..."
        exit 2
    fi
else
    echo "File already exists, exiting..."
    read -p "Do you want to see ssp status [y/n]: " ssp_status
    if [[ $ssp_status == "y" ]]; then
        $status_daemon
    else
        echo "Status cancelled."
    fi
fi

# Instalación de ejecutable
sudo cp "$install_dir/ssp_/ssp.sh" "$install_dir_sbin/ssp"

# Comprobación de instalación exitosa
if [[ -f "$install_dir_sbin/ssp" ]]; then
    echo "Installation Complete"
else
    echo "Error While Installing..."
    for i in {1..5}; do
        sudo cp "$install_dir/ssp_/ssp.sh" "$install_dir_sbin/ssp"
        if [[ -f "$install_dir_sbin/ssp" ]]; then
            echo "Installation Complete"
            break
        fi
    done
fi

# Proceso de instalación de servicios del sistema
read -p "Do you want to install local services? [y/n]: " localservices
if [[ $localservices == "y" ]]; then
    numberinput=-1

    while [[ $numberinput -ne 1 ]]; do
        echo "Select your Operative System:"
        echo "[1] Ubuntu"
        echo "[-] There are no more Operative Systems at the moment." # Mas adelante esto no sera necesario, porque analizara automaticamente las rutas y segun si existen rutas, detectara el sistema operativo en el que se ejecuta
        echo ""
        read -p "Number Input: " numberinput
    done

    if [[ $numberinput == 1 ]]; then
        sudo cp "$install_dir/ssp_/localservices/ubuntu_/localservices.txt" "$allowed_services"
    fi
fi

if [[ -f $allowed_services ]]; then
    echo "File $allowed_services exists"
else
    sudo touch "$allowed_services"
fi

recomendedservicesfile="$install_dir/ssp_/recomendedservices/recomended.txt"

read -p "Would you want recomended services? [y/n]: " recomendedservices
if [[ $recomendedservices == "y" ]]; then
    cat "$recomendedservicesfile" >> "$allowed_services"
else
    echo "Recomended services rejected."
fi

# Permisos
sudo chmod 777 "$install_dir_sbin/ssp"