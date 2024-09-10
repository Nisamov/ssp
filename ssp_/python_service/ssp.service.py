# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal

import subprocess
import time
import logging
import os
from datetime import datetime

# Ruta del archivo de la lista blanca
whitelist_path = "/etc/ssp/allowed_services.txt"
config_path = "/etc/ssp/config/ssp_service.conf"

def initialize_logging(log_level, log_dir):
    """Initializes the logging configuration."""
    # Crear directorio de logs si no existe
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
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

def read_whitelist():
    """Reads the whitelist file and returns a list of allowed services, ignoring lines that start with '#'."""
    try:
        with open(whitelist_path, 'r') as f:
            allowed_services = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        logging.info(f"Allowed services read: {allowed_services}")
        return allowed_services
    except FileNotFoundError:
        logging.error(f"Whitelist file not found: {whitelist_path}")
        return []

def read_config():
    """Reads the configuration file to get timeout and logging configurations."""
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
                        logging.info(f"Configured timeout: {time_sleep} seconds")
                    elif "log_level=" in line:
                        log_level = line.split('=')[1].strip()
                    elif "log_file=" in line:
                        log_dir = line.split('=')[1].strip()

        logging.info(f"Configured log level: {log_level}, log directory: {log_dir}")
    except FileNotFoundError:
        print(f"Configuration file not found: {config_path}")
        logging.error(f"Configuration file not found: {config_path}")
    except ValueError:
        print("Error in timeout format in configuration file.")
        logging.error("Error in timeout format in configuration file.")

    return time_sleep, log_level, log_dir

def get_active_services():
    """Get the list of active services on the system using the 'systemctl' command."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    logging.info(f"Active services detected: {active_services}")
    return active_services

def stop_service(service_name):
    """Stops a disallowed service."""
    logging.info(f"Stopping the service not allowed: {service_name}")
    subprocess.run(['systemctl', 'stop', service_name])

def monitor_services():
    """Infinite loop that monitors active services and compares with allowed services."""
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
