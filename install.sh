#!/bin/bash

# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal
# Instalacion compatible con Ubuntu Desktop/Server, Kali Linux y Debian

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
allowed_services="/etc/ssp/allowed_services.txt"
distro=$(lsb_release -is) # Obtener el Distributor ID
edition="Unknown" # Inicializar la variable de tipo de edición
install_end="/usr/local/sbin/ssp_"

clear # Limpiar consola

if [[ "$distro" == "Ubuntu" ]]; then
    # Comprobar si el paquete ubuntu-desktop o xserver-xorg está instalado
    if dpkg -l | grep -qE "ubuntu-desktop|xserver-xorg"; then
        edition="Desktop"
        builtin echo "OS-Detected:$distro+$edition/:" # Muestra de distribucion + edicion
    elif [ -f /etc/cloud/cloud.cfg ]; then # Buscar un fichero que exista en ubuntu server
        edition="Server" # Si existe el archivo /etc/cloud/build.info, se considera Server
        builtin echo "OS-Detected:$distro+$edition/:" # Muestra de distribucion + edicion
    else
        edition="Server" # Por defecto, se asume Server si no hay entorno gráfico
    fi
else
    builtin echo "OS-Detected:$distro/, SSP is currently compatible with Ubuntu Desktop/Server, Kali & Debian." # Muestra de distribucion
    read -p "Do you want to continue the installation anyways? [y/n]: " keepinstalling
    if [[ $keepinstalling == "y" ]]; then
        builtin echo "Installing for $distro+$edition..."
    else
        builtin echo "Installation stopped."
        builtin exit 1
    fi
fi

builtin echo "Installing dependences from $install_dir" # Simulación de tareas en el script

# Creacion de directorios del servicio
sudo mkdir "$install_end" # Directorio de subprogramas
sudo mkdir "/etc/ssp" # Directorio
sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp" # Instalacion de fichero ejecutable
sudo mv "$install_dir/LICENSE.md" "$install_end/LICENSE.md" # Instalacion de licencia
sudo mkdir "$install_end/py_service" # Creacion de ruta para scripts python
sudo cp "$install_dir/ssp_/python_service/ssp.service.py" "$install_end/py_service/ssp.service.py" # Clonacion servicio y otorgacion de servicios
sudo cp "$install_dir/ssp_/necessaryservices/mainservices.txt" "$allowed_services" # Proceso de instalación de servicios obligatorios para del sistema
sudo mkdir "/etc/ssp/logs" # Creacion de directorio destinado a los logs del servicio
sudo cp "$install_dir/ssp_/ssp_uninstall.sh" "$install_end/" # Clona el fichero de desinstalacion

builtin echo "Configuring main files in $install_end"

# Otorgar permisos 755 a todos los directorios y 644 a todos los archivos dentro de /usr/local/sbin/ssp_
sudo find "$install_end" -type d -exec chmod 755 {} \;  # Directorios
sudo find "$install_end" -type f -exec chmod 644 {} \;  # Archivos
sudo chmod +x "$install_end/py_service/ssp.service.py" # Otorgar permisos de ejecución al script de servicio
sudo chmod 755 "/usr/local/sbin/ssp" # Otorgar permisos al script principal
sudo chmod 755 "$install_end/ssp_uninstall.sh" # Otorgar permisos al script de desinstalación
sudo mkdir -p /etc/ssp/logs # Crear el directorio /etc/ssp/logs
sudo chmod 755 /etc/ssp/logs # Otorgar permisos
sudo chmod 755 /etc/ssp # Otorgar permisos al directorio /etc/ssp

builtin echo "Configuring $allowed_services & recommended $install_dir/ssp_/recomendedservices/recomended.txt"

builtin read -p "Do you want to install local services? [y/n]: " localservices # Proceso de instalacion de servicios locales (Para ubuntu)
if [[ $localservices == "y" ]]; then
# Tras haber aceptado los servicios locales, se continua con el proceso de seleccion
    if [[ $distro == "Ubuntu" && $edition == "Server" ]]; then
    # Si el sistema es ubuntu server
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/ubuntuserver/localservices.txt" >> "$allowed_services" # Agrega los servicios de ubuntu server
    elif [[ $distro == "Ubuntu" && $edition == "Desktop" ]]; then
    # Si el sistema es ubuntu desktop
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/ubuntudesktop/localservices.txt" >> "$allowed_services" # Agrega los servicios de ubuntu desktop
    elif [[ $distro == "Kali" ]]; then
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/kalilinux/localservices.txt" >> "$allowed_services" # Agrega los servicios de Kali linux
    elif [[ $distro == "Debian" ]]; then
        sed -i -e '$a\' "$allowed_services" # Asegurarse de que allowed_services termine con una nueva línea
        cat "$install_dir/ssp_/localservices/debian/localservices.txt" >> "$allowed_services" # Agrega los servicios de Debian

    else
        builtin echo "There has been an error during installation."
        builtin echo "Distro: $distro | Edition: $edition - Has not been found."
        builtin exit 1
    fi
fi

# Proceso de instalacion de servicios por recomendacion
recomendedservicesfile="$install_dir/ssp_/recomendedservices/recomended.txt"
builtin read -p "Would you want recommended services? [y/n]: " recomendedservices
if [[ $recomendedservices == "y" ]]; then
    # Asegurarse de que allowed_services termine con una nueva línea
    sed -i -e '$a\' "$allowed_services"
    cat "$recomendedservicesfile" >> "$allowed_services"
else
    builtin echo "Action cancelled."
fi

builtin echo "Creating service with $install_dir/ssp_/bash_file/systemd_contruct.sh"

sudo bash "$install_dir/ssp_/bash_file/systemd_contruct.sh" # Llamar al generador de servicio

builtin echo "Liberating vairables $install_dir, $allowed_services, $distro, $edition, $install_end"

unset install_dir # Libera la variable después de usarla
unset allowed_services # Libera la variable después de usarla
unset distro # Libera la variable después de usarla
unset edition # Libera la variable después de usarla
unset install_end # Libera la variable después de usarla

builtin echo "Loading daemon..."

sudo systemctl daemon-reload # Recargar el demonio
sudo systemctl unmask ssp.service # Desenmascarar demonio
sudo systemctl enable ssp.service # Habilitar demonio
sudo systemctl start ssp.service # Iniciar demonio
# sudo systemctl status ssp.service # Mostrar el estado en el que se encuentra el demonio

builtin echo "Daemon loaded"

clear # Limpiar consola
builtin echo "Service installed correctly" # Mensaje finalizacion de script
builtin exit 1 # Codigo de salida