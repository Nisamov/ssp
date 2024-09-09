#!/bin/bash

# Spec.0 License 2024 Andres Rulsan Abadias Otal

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/allowed_services.txt"
# Gestion del servicio
reload_daemon="sudo systemctl daemon-reload"
unmask_daemon="sudo systemctl unmask ssp.service"
enable_daemon="sudo systemctl enable ssp.service"
status_daemon="sudo systemctl status ssp.service"
# Definimos el tamaño total de la barra de progreso
TOTAL=50
# Inicializamos la variable progreso
progreso=0
# Función para mostrar la barra de progreso
mostrar_barra_progreso() {
    # Calcula el número de almohadillas y guiones que se deben mostrar
    completado=$((progreso * TOTAL / 100))
    faltante=$((TOTAL - completado))

    # Construye la barra de progreso con almohadillas (#) y guiones (-)
    barra=$(printf "%0.s#" $(seq 1 $completado))
    barra+=$(printf "%0.s-" $(seq 1 $faltante))

    # Muestra la barra de progreso con el porcentaje completado
    printf "\r[%s] %d%%" "$barra" "$progreso"
}
# Función para aumentar el progreso
incrementar_progreso() {
    paso=$1
    progreso=$((progreso + paso))
    if [ "$progreso" -gt 100 ]; then
        progreso=100
    fi
    mostrar_barra_progreso
}

clear # Limpiar consola

echo "Installing dependences..." # Simulación de tareas en el script
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 10/100
clear # Limpiar consola

# Creacion de directorios del servicio
sudo mkdir "/usr/local/sbin/ssp_" #   Directorio de subprogramas
sudo mkdir "/etc/ssp" #   Directorio de configuracion

sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp" # Instalacion de fichero ejecutable

sudo chmod 777 "/usr/local/sbin/ssp" # Otorgar permisos al script

sudo mv "$install_dir/LICENSE.md" "/usr/local/sbin/ssp_/LICENSE.md" # Instalacion de licencia

echo "Installing main files..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 20/100
clear # Limpiar consola

sudo mkdir "/usr/local/sbin/ssp_/py_service" # Creacion de ruta para scripts python

sudo cp "$install_dir/ssp_/python_service/ssp.service.py" "/usr/local/sbin/ssp_/py_service/ssp.service.py" # Clonacion servicio y otorgacion de servicios
sudo chmod +x "/usr/local/sbin/ssp_/py_service/ssp.service.py"

echo "Cloning services..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 30/100
clear # Limpiar consola

cp "$install_dir/ssp_/necessaryservices/mainservices.txt" "$allowed_services" # Proceso de instalación de servicios obligatorios para del sistema

read -p "Do you want to install local services? [y/n]: " localservices # Proceso de instalacion de servicios locales (Para ubuntu)
if [[ $localservices == "y" ]]; then
    sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
    cat "$install_dir/ssp_/localservices/ubuntu_/localservices.txt" >> "$allowed_services"
fi

# Proceso de instalacion de servicios por recomendacion
recomendedservicesfile="$install_dir/ssp_/recomendedservices/recomended.txt"
read -p "Would you want recommended services? [y/n]: " recomendedservices
if [[ $recomendedservices == "y" ]]; then
    # Asegurarse de que allowed_services termine con una nueva línea
    sed -i -e '$a\' "$allowed_services"
    cat "$recomendedservicesfile" >> "$allowed_services"
else
    echo "Action cancelled."
fi

echo "Creating service..."
incrementar_progreso 30 # Incrementa el progreso en 10% | Status actual 60/100
clear # Limpiar consola

sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh" # Llamar al generador de servicio

echo "Loading configuration file..."
incrementar_progreso 20 # Incrementa el progreso en 20% | Status actual 80/100
clear # Limpiar consola

sudo cp -r "$install_dir/ssp_/config" "/etc/ssp/" # Mover directorio con configuracion a /etc/ssp/

echo "Loading daemon..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 90/100
clear # Limpiar consola

sudo systemctl daemon-reload # Recargar el demonio
sudo systemctl unmask ssp.service # Desenmascarar demonio
sudo systemctl enable ssp.service # Habilitar demonio
sudo systemctl start ssp.service # Iniciar demonio
# sudo systemctl status ssp.service #Mostrar el estado en el que se encuentra el demonio

incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 100/100
clear # Limpiar consola

echo "Service installed correctly" # Mensaje finalizacion de script
exit 1 # Codigo de salida