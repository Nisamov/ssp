import os
import time

# Codigo activo de Secure Service Protocol : Ruta del fichero: /usr/local/sbin/ssp/py_service/ssp.service.py

# Bucle infinito
def main():
    while True:
        print("El servicio está corriendo...")
        time.sleep(60)  # Espera 60 segundos antes de la siguiente iteración.

if __name__ == "__main__":
    main()