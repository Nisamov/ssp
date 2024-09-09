#!/bin/bash

allowed_services="/etc/ssp/allowed_services.txt"

# Ejemplo de ejcucion:
# ssp -a -> Añadir servicio
# ssp -r -> Eliminar servicio
# ssp -d -> Desinstalar servicio y relacionados
# ssp -s -> Mostrar servicios permitidos (con less)

if [[ $1 == "-a" || $1 == "--add" ]]; then
    # Confirmacion
    read -p "Are you sure you want to add '$2' to whitelist? [y/n]: " newserviceaccept
    if [[ $newserviceaccept == "y" ]]; then
        sudo echo $2 >> "$allowed_services"
        echo "'$2' service added to whitelist."
    else
        echo "Action cancelled."
    fi
elif [[ $1 == "-r" || $1 == "--remove" ]]; then
    sudo sed -i "/$2/d" "$allowed_services"
    echo "Servicio $2 eliminado de la lista permitida"
elif [[ $1 == "-u" || $1 == "--uninstall" ]]; then
    echo "Desinstalando programa..."
elif [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Use: $0 { -a / --add (Add service to list) | -r / --remove (Remove service from list) | -u / --uninstall (Uninstall software) | -h / --help (show this help)}."
else
    echo "Use: $0 { -a / --add (Add service to list) | -r / --remove (Remove service from list) | -u / --uninstall (Uninstall software) | -h / --help (show this help)}."
fi