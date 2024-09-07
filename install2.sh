#!/bin/bash

# Modelo 2 instalacion

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"
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

# Limpiar consola
clear

# Simulación de tareas en el script
echo "Installing dependences..."
sleep 1  # Simulación del tiempo de ejecución

# Creacion de directorios del servicio
#   Directorio de subprogramas
sudo mkdir "/usr/local/sbin/ssp_"
#   Directorio de configuracion
sudo mkdir "/etc/ssp"

# Instalacion de fichero ejecutable
sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp"

# Otorgar permisos al script
sudo chmod 777 "/usr/local/sbin/ssp"

# Instalacion de licencia
sudo mv "$install_dir/LICENSE.md" "/usr/local/sbin/ssp_/LICENSE.md"

echo "Installing main files..."
# Incrementa el progreso en 10%
incrementar_progreso 10
sleep 1  # Simulación del tiempo de ejecución

# Creacion de ruta para scripts python
sudo mkdir "/usr/local/sbin/ssp_/py_service"

# Clonacion servicio y otorgacion de servicios
sudo cp "$install_dir/ssp_/python_service/ssp.service.py" "/usr/local/sbin/ssp_/py_service/ssp.service.py"
sudo chmod +x "/usr/local/sbin/ssp_/py_service/ssp.service.py"

echo "Cloning services..."
# Incrementa el progreso en 10%
incrementar_progreso 10
sleep 1  # Simulación del tiempo de ejecución

# Llamar al generador de servicio
sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh"

echo "Starting service ssp.service..."
# Incrementa el progreso en 10%
incrementar_progreso 10
sleep 1  # Simulación del tiempo de ejecución