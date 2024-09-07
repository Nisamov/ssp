#!/bin/bash

# Modelo 2 instalacion

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"


function progreso () #crear una funcion (progreso)
{
typeset -i i=0
while [ $i -le "20" ] #creamos el ciclo
do
echo -e "\033[44m\033[30m \033[0m \\c" #coloca un espacio en color
azul que indique la barra de progreso
sleep 1 #damos un intervalo de 1 seg
i=i+1
done
}
#####Main#####
progreso # llamamos la funcion dentro del shell




# Creacion de directorios del servicio
#   Directorio de subprogramas
sudo mkdir "/usr/local/sbin/ssp_"
#   Directorio de configuracion
sudo mkdir "/etc/ssp"

# Instalacion de fichero ejecutable
sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp"

# Otorgar permisos al script
sudo chmod 777 "/usr/local/sbin/ssp"