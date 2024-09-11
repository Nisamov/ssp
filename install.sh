#!/bin/bash

# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal
# Instalacion compatible con Ubuntu Desktop/Server

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/allowed_services.txt"
distro=$(lsb_release -is) # Obtener el Distributor ID
edition="Unknown" # Inicializar la variable de tipo de edición
TOTAL=50 # Definimos el tamaño total de la barra de progreso
progreso=0 # Inicializamos la variable progreso
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

echo "Checking OS..." # Simulación de tareas en el script
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 10/100
clear # Limpiar consola

if [[ "$distro" == "Ubuntu" ]]; then
    # Comprobar si el paquete ubuntu-desktop o xserver-xorg está instalado
    if dpkg -l | grep -qE "ubuntu-desktop|xserver-xorg"; then
        edition="Desktop"
    elif [ -f /etc/cloud/build.info ]; then
        edition="Server" # Si existe el archivo /etc/cloud/build.info, se considera Server
    else
        edition="Server" # Por defecto, se asume Server si no hay entorno gráfico
    fi
else
    echo "It is not an Ubuntu Distro."
    exit 1
fi

echo "Installing dependences..." # Simulación de tareas en el script
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 20/100
clear # Limpiar consola

# Creacion de directorios del servicio
sudo mkdir "/usr/local/sbin/ssp_" # Directorio de subprogramas
sudo mkdir "/etc/ssp" # Directorio
sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp" # Instalacion de fichero ejecutable
sudo mv "$install_dir/LICENSE.md" "/usr/local/sbin/ssp_/LICENSE.md" # Instalacion de licencia
sudo mkdir "/usr/local/sbin/ssp_/py_service" # Creacion de ruta para scripts python
sudo cp "$install_dir/ssp_/python_service/ssp.service.py" "/usr/local/sbin/ssp_/py_service/ssp.service.py" # Clonacion servicio y otorgacion de servicios
sudo cp "$install_dir/ssp_/necessaryservices/mainservices.txt" "$allowed_services" # Proceso de instalación de servicios obligatorios para del sistema
sudo mkdir "/etc/ssp/logs" # Creacion de directorio destinado a los logs del servicio

echo "Configuring main files..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 30/100
clear # Limpiar consola

# Otorgar permisos 755 a todos los directorios y 644 a todos los archivos dentro de /usr/local/sbin/ssp_
sudo find "/usr/local/sbin/ssp_" -type d -exec chmod 755 {} \;  # Directorios
sudo find "/usr/local/sbin/ssp_" -type f -exec chmod 644 {} \;  # Archivos
sudo chmod +x "/usr/local/sbin/ssp_/py_service/ssp.service.py" # Otorgar permisos de ejecución al script de servicio
sudo chmod 755 "/usr/local/sbin/ssp" # Otorgar permisos al script principal
sudo chmod 755 "/usr/local/sbin/ssp_/ssp_uninstall.sh" # Otorgar permisos al script de desinstalación
sudo mkdir -p /etc/ssp/logs # Crear el directorio /etc/ssp/logs
sudo chmod 755 /etc/ssp/logs # Otorgar permisos
sudo chmod 755 /etc/ssp # Otorgar permisos al directorio /etc/ssp

echo "Configuring local & recommended services..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 40/100
clear # Limpiar consola

read -p "Do you want to install local services? [y/n]: " localservices # Proceso de instalacion de servicios locales (Para ubuntu)
if [[ $localservices == "y" ]]; then
# Tras haber aceptado los servicios locales, se continua con el proceso de seleccion
    if [[ $edition == "Server" ]]; then
    # Si el sistema es ubuntu server
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/ubuntuserver/localservices.txt" >> "$allowed_services"
    elif [[ $edition == "Desktop" ]]; then
    # Si el sistema es ubuntu desktop
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/ubuntudesktop/localservices.txt" >> "$allowed_services"
    else
        echo "There has been an error during installation."
        echo "Distro: $distro | Edition: $edition - Has not been found."
        exit 1
    fi
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
incrementar_progreso 30 # Incrementa el progreso en 10% | Status actual 70/100
clear # Limpiar consola

sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh" # Llamar al generador de servicio

echo "Loading configuration file..."
incrementar_progreso 10 # Incrementa el progreso en 20% | Status actual 80/100
clear # Limpiar consola

sudo cp "$install_dir/ssp_/ssp_uninstall.sh" "/usr/local/sbin/ssp_"

echo "Loading daemon..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 90/100
clear # Limpiar consola

sudo systemctl daemon-reload # Recargar el demonio
sudo systemctl unmask ssp.service # Desenmascarar demonio
sudo systemctl enable ssp.service # Habilitar demonio
sudo systemctl start ssp.service # Iniciar demonio
# sudo systemctl status ssp.service # Mostrar el estado en el que se encuentra el demonio

echo "Daemon loaded"
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 100/100
clear # Limpiar consola

echo "Service installed correctly" # Mensaje finalizacion de script
exit 1 # Codigo de salida