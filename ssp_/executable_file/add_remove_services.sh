#!/bin/bash
ALLOWED_SERVICES="/etc/ssp/permitted_services.txt"

case $1 in
    add)
        echo $2 >> "$ALLOWED_SERVICES"
        echo "Servicio $2 añadido a la lista permitida"
        ;;
    remove)
        sed -i "/$2/d" "$ALLOWED_SERVICES"
        echo "Servicio $2 eliminado de la lista permitida"
        ;;
    *)
        echo "Uso: $0 {add|remove} servicio"
        ;;
esac