import subprocess
import configparser
import time
import logging
import os
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

    # Comprobación de los valores de configuración leídos
    print(f"Initializing logging with log_level: {log_level}, log_dir: {log_dir}")

    # Crear directorio de logs si no existe
    if not os.path.exists(log_dir):
        try:
            os.makedirs(log_dir, exist_ok=True)
            print(f"Log directory created: {log_dir}")
        except Exception as e:
            print(f"Failed to create log directory {log_dir}: {e}")
            return

    # Establecer la hora de inicio para el archivo de log
    log_file_start_time = datetime.now()

    # Configuración del logger principal
    main_logger = logging.getLogger('MainLogger')
    main_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))  # Predeterminado a INFO si no es válido

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
        print(f"Log file created: {log_path}")
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
        main_logger.info(f"Allowed services read: {allowed_services}")
        return allowed_services
    except FileNotFoundError:
        main_logger.error(f"Whitelist file not found: {whitelist_path}")
        return []
    
def read_config():
    """Lee el archivo de configuración para obtener el tiempo de espera y la configuración de logging."""
    # Valores predeterminados
    time_sleep = 5
    log_level = 'INFO'
    log_dir = '/etc/ssp/logs/'
    chng_log_interval = 5
    srvcs_dtnd = 'detention_services'

    print(f"Intentando leer el archivo de configuración desde: {config_path}")  # Mensaje de depuración

    config = configparser.ConfigParser()
    
    if not os.path.isfile(config_path):
        print(f"Configuration file not found: {config_path}")
        return time_sleep, log_level, log_dir, chng_log_interval, srvcs_dtnd
    
    try:
        config.read(config_path)
        
        # Verificar si la sección y las opciones existen en el archivo
        if 'DEFAULT' in config:
            time_sleep = config.getint('DEFAULT', 'time_sleep', fallback=time_sleep)
            log_level = config.get('DEFAULT', 'log_level', fallback=log_level)
            log_dir = config.get('DEFAULT', 'log_dir', fallback=log_dir)
            chng_log_interval = config.getint('DEFAULT', 'chng_log_file', fallback=chng_log_interval)
            srvcs_dtnd = config.get('DEFAULT', 'srvcs_dtnd', fallback=srvcs_dtnd)
        
        print("Archivo de configuración leído con éxito.")  # Confirmación de lectura exitosa

    except configparser.Error as e:
        print(f"Error en el archivo de configuración: {e}")

    # Imprimir valores leídos para verificar
    print(f"Configuración leída: time_sleep={time_sleep}, log_level={log_level}, log_dir={log_dir}, chng_log_interval={chng_log_interval}, srvcs_dtnd={srvcs_dtnd}")

    return time_sleep, log_level, log_dir, chng_log_interval, srvcs_dtnd

def get_active_services():
    """Obtiene la lista de servicios activos en el sistema utilizando el comando 'systemctl'."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    main_logger.info(f"Active services detected: {active_services}")
    return active_services

def stop_service(service_name):
    """Detiene un servicio no permitido y lo registra en el archivo de servicios detenidos."""
    main_logger.info(f"Stopping the service not allowed: {service_name}")
    detention_logger.warning(f"Service stopped: {service_name}")
    subprocess.run(['systemctl', 'stop', service_name])

def monitor_services():
    """Bucle infinito que monitorea los servicios activos y los compara con los servicios permitidos."""
    # Leer el tiempo de espera y configuración de logging del archivo de configuración
    time_sleep, log_level, log_dir, chng_log_interval, srvcs_dtnd = read_config()

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

        # Esperar el tiempo configurado antes de la siguiente comprobación
        time.sleep(time_sleep)

if __name__ == "__main__":
    monitor_services()