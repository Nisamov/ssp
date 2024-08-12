#!/bin/bash

ALLOWED_SERVICES="/etc/ssp/permitted_services.txt"

# Ejemplo de ejcucion:
# ssp -a -> Añadir servicio
# ssp -r -> Eliminar servicio
# ssp -d -> Desinstalar servicio y relacionados
# ssp -s -> Mostrar servicios permitidos (con less)

if [[ $2 == "-a" ]]; then
    sudo echo $2 >> "$ALLOWED_SERVICES"
    echo "Servicio $2 añadido a la lista permitida"
elif [[ $2 == "-r" ]]; then
    sudo sed -i "/$2/d" "$ALLOWED_SERVICES"
    echo "Servicio $2 eliminado de la lista permitida"
elif [[ $2 == "-d" ]]; then
    echo "Desinstalando programa..."
else
     echo "Uso: $0 { -a (Add service to list) | -r (Remove service from list) | -d (Uninstall software) } servicio"
fi