import subprocess
import time

# Ruta del archivo de la lista blanca
whitelist_path = "/etc/ssp/permitted_services.txt"

def read_whitelist():
    """Lee el archivo de la lista blanca y devuelve una lista de servicios permitidos, ignorando líneas que comienzan con '#'."""
    with open(whitelist_path, 'r') as f:
        permitted_services = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    print(f"Servicios permitidos leídos: {permitted_services}")  # Depuración
    return permitted_services

def get_active_services():
    """Obtiene la lista de servicios activos en el sistema utilizando el comando 'systemctl'."""
    result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager', '--no-legend'],
                            stdout=subprocess.PIPE, text=True)
    active_services = [line.split()[0] for line in result.stdout.splitlines()]
    print(f"Servicios activos detectados: {active_services}")  # Depuración
    return active_services

def monitor_services():
    """Bucle infinito que monitoriza los servicios activos y compara con los servicios permitidos."""
    while True:
        # Leer la lista de servicios permitidos
        permitted_services = read_whitelist()

        # Obtener la lista de servicios activos
        active_services = get_active_services()

        # Comparar servicios activos con la lista blanca
        for service in active_services:
            if service not in permitted_services:
                print(f"Servicio no permitido detectado: {service}")

        # Por agregar:
        # Si hay un servicio no permitido detectado, no solo lo avisa en la consola, sino que lo cierra automaticamente


        # Esperar un tiempo antes de la siguiente comprobación (5 segundos)
        time.sleep(5)

if __name__ == "__main__":
    monitor_services()
