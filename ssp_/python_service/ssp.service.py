import os
import subprocess
import time
import logging
from datetime import datetime, timedelta

# Ruta del archivo de la lista blanca y de configuración
whitelist_path = "/etc/ssp/allowed_services.txt"
config_path = "/etc/ssp/config/ssp_service.conf"

# Variables globales para logging
log_file_start_time = None
main_logger = None
detention_logger = None

def initialize_logging(log_level, log_dir, chng_log_interval, srvcs_dtnd):
    """Inicializa la configuración de logging y crea loggers separados para logs generales y servicios detenidos."""
    global main_logger, detention_logger, log_file_start_time

    # Crear directorio de logs si no existe
    if not os.path.exists(log_dir):
        try:
            os.makedirs(log_dir, exist_ok=True)
        except Exception as e:
            print(f"Failed to create log directory {log_dir}: {e}")
            return

    # Establecer la hora de inicio para el archivo de log
    log_file_start_time = datetime.now()

    # Configuración del logger principal
    main_logger = logging.getLogger('MainLogger')
    main_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    # Limpiar manejadores anteriores antes de añadir uno nuevo
    if main_logger.hasHandlers():
        main_logger.handlers.clear()

    # Actualizar archivo de log para el logger principal
    update_log_file(log_dir)

    # Configuración del logger para servicios detenidos
    detention_log_path = os.path.join(log_dir, f"{srvcs_dtnd}.log")
    detention_logger = logging.getLogger('DetentionLogger')
    detention_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    # Limpiar manejadores anteriores antes de añadir uno nuevo
    if detention_logger.hasHandlers():
        detention_logger.handlers.clear()

    detention_handler = logging.FileHandler(detention_log_path)
    detention_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    detention_logger.addHandler(detention_handler)

    main_logger.info("Logging initialized")

def update_log_file(log_dir):
    """Actualiza el archivo de log del logger principal según el tiempo actual."""
    global log_file_start_time, main_logger

    # Comprobar si ha pasado el tiempo de intervalo para cambiar el archivo de log
    log_filename = datetime.now().strftime("%M_%H!%d_%m_%Y.log")
    log_path = os.path.join(log_dir, log_filename)

    # Crear un nuevo manejador de archivo
    try:
        file_handler = logging.FileHandler(log_path)
        file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))

        # Limpiar manejadores anteriores y añadir el nuevo manejador
        if main_logger.hasHandlers():
            main_logger.handlers.clear()
        main_logger.addHandler(file_handler)

        log_file_start_time = datetime.now()
    except Exception as e:
        print(f"Failed to create log file {log_path}: {e}")

def check_and_update_log_file(log_dir, chng_log_interval):
    """Verifica si es necesario cambiar el archivo de log cada `chng_log_interval` minutos."""
    global log_file_start_time

    # Calcular la diferencia de tiempo
    time_diff = datetime.now() - log_file_start_time
    if time_diff > timedelta(minutes=chng_log_interval):
        update_log_file(log_dir)

def read_whitelist():
    """Lee el archivo de lista blanca y devuelve una lista de servicios permitidos, ignorando líneas que comienzan con '#'."""
    try:
        with open(whitelist_path, 'r') as f:
            allowed_services = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        return allowed_services
    except FileNotFoundError:
        print(f"Whitelist file not found: {whitelist_path}")
        return []

def read_config():
    """Lee el archivo de configuración para obtener la configuración de logging."""
    # Valores predeterminados
    log_level = None
    log_dir = None
    chng_log_interval = None
    srvcs_dtnd = None

    try:
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    if "log_level=" in line:
                        log_level = line.split('=')[1].strip()
                    elif "log_dir=" in line:
                        log_dir = line.split('=')[1].strip()
                    elif "chng_log_file=" in line:
                        chng_log_interval = int(line.split('=')[1].strip())
                    elif "srvcs_dtnd=" in line:
                        srvcs_dtnd = line.split('=')[1].strip()

        # Verificar qué valores no se encontraron
        if log_level is None:
            print("Error: 'log_level' no encontrado en el archivo de configuración.")
        if log_dir is None:
            print("Error: 'log_dir' no encontrado en el archivo de configuración.")
        if chng_log_interval is None:
            print("Error: 'chng_log_interval' no encontrado en el archivo de configuración.")
        if srvcs_dtnd is None:
            print("Error: 'srvcs_dtnd' no encontrado en el archivo de configuración.")

        return log_level, log_dir, chng_log_interval, srvcs_dtnd

    except FileNotFoundError:
        print(f"Configuration file not found: {config_path}")
        return None, None, None, None
    except ValueError as e:
        print(f"Error en el formato del archivo de configuración: {e}")
        return None, None, None, None

def get_active_services():
    """Obtiene la lista de servicios activos en el sistema utilizando el comando 'systemctl'."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    return active_services

def stop_service(service_name):
    """Detiene un servicio no permitido y lo registra en el archivo de servicios detenidos."""
    main_logger.info(f"Stopping the service not allowed: {service_name}")
    detention_logger.warning(f"Service stopped: {service_name}")
    subprocess.run(['systemctl', 'stop', service_name])

def monitor_services():
    """Bucle infinito que monitorea los servicios activos y los compara con los servicios permitidos."""
    # Leer la configuración
    log_level, log_dir, chng_log_interval, srvcs_dtnd = read_config()

    if None in (log_level, log_dir, chng_log_interval, srvcs_dtnd):
        print("Error en la configuración. El servicio no puede continuar.")
        return

    # Inicializar logging
    initialize_logging(log_level, log_dir, chng_log_interval, srvcs_dtnd)

    while True:
        # Verificar y actualizar el archivo de log si es necesario
        check_and_update_log_file(log_dir, chng_log_interval)

        # Leer la lista de servicios permitidos
        allowed_services = read_whitelist()

        # Obtener la lista de servicios activos
        active_services = get_active_services()

        # Comparar servicios activos con la lista blanca
        for service in active_services:
            if service not in allowed_services:
                main_logger.warning(f"Service not allowed detected: {service}")
                stop_service(service)  # Detener el servicio no permitido

        # Esperar 5 segundos antes de la siguiente comprobación (se puede ajustar según necesidad)
        time.sleep(5)

if __name__ == "__main__":
    monitor_services()