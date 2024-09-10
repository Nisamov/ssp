import subprocess
import time
import logging
import os
from datetime import datetime

# Ruta del archivo de la lista blanca y de configuración
whitelist_path = "/etc/ssp/allowed_services.txt"
config_path = "/etc/ssp/config/ssp_service.conf"

def initialize_logging(log_level, log_dir):
    """Inicializa la configuración de logging."""
    try:
        # Crear directorio de logs si no existe
        if not os.path.exists(log_dir):
            os.makedirs(log_dir, exist_ok=True)
        
        # Formato de nombre del archivo de log: minuto_hora!dia_mes_año.log
        log_filename = datetime.now().strftime("%M_%H!%d_%m_%Y.log")
        log_path = os.path.join(log_dir, log_filename)

        # Configuración del logger
        numeric_level = getattr(logging, log_level.upper(), None)
        if not isinstance(numeric_level, int):
            raise ValueError(f'Invalid log level: {log_level}')
        
        logging.basicConfig(
            filename=log_path,
            level=numeric_level,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        logging.info("Logging initialized")
    except PermissionError as e:
        print(f"Permission error: {e}. Cannot write to log directory {log_dir}.")
        exit(1)

def read_whitelist():
    """Lee el archivo de lista blanca y devuelve una lista de servicios permitidos, ignorando líneas que comienzan con '#'."""
    try:
        with open(whitelist_path, 'r') as f:
            allowed_services = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        logging.info(f"Allowed services read: {allowed_services}")
        return allowed_services
    except FileNotFoundError:
        logging.error(f"Whitelist file not found: {whitelist_path}")
        return []

def read_config():
    """Lee el archivo de configuración para obtener el tiempo de espera y la configuración de logging."""
    time_sleep = 5  # Valor por defecto
    log_level = 'INFO'
    log_dir = '/etc/ssp/logs/'

    try:
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    if "time_sleep=" in line:
                        time_sleep = int(line.split('=')[1].strip())
                    elif "log_level=" in line:
                        log_level = line.split('=')[1].strip()
                    elif "log_dir=" in line:  # Usando "log_dir" según la nueva configuración
                        log_dir = line.split('=')[1].strip()

    except FileNotFoundError:
        print(f"Configuration file not found: {config_path}")
    except ValueError:
        print("Error in timeout format in configuration file.")

    return time_sleep, log_level, log_dir

def get_active_services():
    """Obtiene la lista de servicios activos en el sistema utilizando el comando 'systemctl'."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    logging.info(f"Active services detected: {active_services}")
    return active_services

def stop_service(service_name):
    """Detiene un servicio no permitido."""
    logging.info(f"Stopping the service not allowed: {service_name}")
    subprocess.run(['systemctl', 'stop', service_name])

def monitor_services():
    """Bucle infinito que monitorea los servicios activos y los compara con los servicios permitidos."""
    # Leer el tiempo de espera y configuración de logging del archivo de configuración
    time_sleep, log_level, log_dir = read_config()

    # Inicializar logging
    initialize_logging(log_level, log_dir)

    while True:
        # Leer la lista de servicios permitidos
        allowed_services = read_whitelist()

        # Obtener la lista de servicios activos
        active_services = get_active_services()

        # Comparar servicios activos con la lista blanca
        for service in active_services:
            if service not in allowed_services:
                logging.warning(f"Service not allowed detected: {service}")
                stop_service(service)  # Detener el servicio no permitido

        # Esperar el tiempo configurado antes de la siguiente comprobación
        time.sleep(time_sleep)

if __name__ == "__main__":
    monitor_services()