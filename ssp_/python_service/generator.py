import os

# Ruta del archivo de configuración
config_path = '/etc/ssp/config/ssp_service.conf'

def generate_config_file(log_interval, stop_services, log_dir):
    """Genera un archivo de configuración con los valores especificados."""
    config_content = f"""# SSPC | Secure Service Protocol Configuration
# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal

# time_sleep: Tiempo en segundos entre cada chequeo de la lista blanca y los servicios activos.
# Este valor controla la frecuencia con la que el programa revisa y detiene servicios no permitidos.
# Ejemplo: time_sleep=10 (revisar cada 10 segundos)
time_sleep=5

# Configuración de logging
log_level=INFO
# Direccion de almacenamiento de los registros.
log_dir={log_dir}

# chng_log_file: Tiempo en minutos entre creación de cada fichero log.
# Este valor controla el tiempo (minutos) con el cual se crean logs.
# Ejemplo: chng_log_file=60 (crear log cada 60 min / 1hora)
chng_log_file={log_interval}

# Nombre de log para los servicios detenidos
# Si se cambia el nombre se creará un nuevo fichero automáticamente con el mismo, dejando el anterior con los servicios detenidos anteriores.
srvcs_dtnd=StoppedServices

# stop_services: Habilitar o deshabilitar la detención de servicios no reconocidos.
# Si es 'True', los servicios no reconocidos serán detenidos. Si es 'False', solo se mostrará una advertencia.
stop_services={str(stop_services).lower()}
"""

    try:
        with open(config_path, 'w') as config_file:
            config_file.write(config_content)
        print(f"Configuration file created or updated at: {config_path}")
    except Exception as e:
        print(f"Failed to write configuration file: {e}")

if __name__ == "__main__":
    # Valores de ejemplo, puedes modificar estos valores según sea necesario
    log_interval = 5  # Tiempo en minutos para la generación de logs
    stop_services = True  # Habilitar o deshabilitar la detención de servicios no reconocidos
    log_dir = '/etc/ssp/logs'  # Ruta donde se generarán los logs

    # Generar el archivo de configuración con los valores especificados
    generate_config_file(log_interval, stop_services, log_dir)
