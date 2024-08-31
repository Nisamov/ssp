#!/bin/bash

ALLOWED_SERVICES="/etc/ssp/permitted_services.txt"

# Ejemplo de ejcucion:
# ssp -a -> Añadir servicio
# ssp -r -> Eliminar servicio
# ssp -d -> Desinstalar servicio y relacionados
# ssp -s -> Mostrar servicios permitidos (con less)

if [[ $1 == "-a" ]]; then
    # Confirmacion
    read -p "Are you sure you want to add '$2' to whitelist? [y/n]: " newserviceaccept
    if [[ $newserviceaccept == "y" ]]; then
        sudo echo $2 >> "$ALLOWED_SERVICES"
        echo "'$2' service added to whitelist."
    else
        echo "Action cancelled."
    fi
elif [[ $1 == "-r" ]]; then
    sudo sed -i "/$2/d" "$ALLOWED_SERVICES"
    echo "Servicio $2 eliminado de la lista permitida"
elif [[ $1 == "-d" ]]; then
    echo "Desinstalando programa..."
else
     echo "Uso: $0 { -a (Add service to list) | -r (Remove service from list) | -d (Uninstall software) } servicio"
fi