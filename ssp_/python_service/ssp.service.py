# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal

import subprocess
import time

# Ruta del archivo de la lista blanca
whitelist_path = "/etc/ssp/allowed_services.txt"
config_path = "/etc/ssp/config/ssp_service.conf"

def read_whitelist():
    """Lee el archivo de la lista blanca y devuelve una lista de servicios permitidos, ignorando líneas que comienzan con '#'."""
    with open(whitelist_path, 'r') as f:
        allowed_services = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    print(f"Servicios permitidos leídos: {allowed_services}")  # Depuración
    return allowed_services

def read_config():
    """Lee el archivo de configuración para obtener el tiempo de espera."""
    try:
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and "time_sleep=" in line:
                    # Extraer el valor de tiempo en segundos después de 'time_sleep='
                    time_sleep = int(line.split('=')[1].strip())
                    print(f"Tiempo de espera configurado: {time_sleep} segundos")  # Depuración
                    return time_sleep
    except FileNotFoundError:
        print(f"No se encontró el archivo de configuración: {config_path}")
    except ValueError:
        print("Error en el formato de tiempo de espera en el archivo de configuración.")

    # Valor por defecto si no se encuentra el tiempo de espera en el archivo
    return 5

def get_active_services():
    """Obtiene la lista de servicios activos en el sistema utilizando el comando 'systemctl'."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    print(f"Servicios activos detectados: {active_services}")  # Depuración
    return active_services

def stop_service(service_name):
    """Detiene un servicio no permitido."""
    print(f"Deteniendo el servicio no permitido: {service_name}")  # Depuración
    subprocess.run(['systemctl', 'stop', service_name])

def monitor_services():
    """Bucle infinito que monitoriza los servicios activos y compara con los servicios permitidos."""
    while True:
        # Leer la lista de servicios permitidos
        allowed_services = read_whitelist()

        # Leer el tiempo de espera del archivo de configuración
        time_sleep = read_config()

        # Obtener la lista de servicios activos
        active_services = get_active_services()

        # Comparar servicios activos con la lista blanca
        for service in active_services:
            if service not in allowed_services:
                print(f"Servicio no permitido detectado: {service}")
                stop_service(service)  # Detener el servicio no permitido

        # Esperar el tiempo configurado antes de la siguiente comprobación
        time.sleep(time_sleep)

if __name__ == "__main__":
    monitor_services()