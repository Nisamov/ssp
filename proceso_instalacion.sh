#!/bin/bash
# Compartido por Nisamov
# Proceso de instalacion con output

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

builtin echo "Nisamov helped in this"
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 10/100
clear
builtin echo "Execution complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 20/100
clear
builtin echo "Local files complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 30/100
clear
builtin echo "Example complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 40/100
clear
builtin echo "Tmp files complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 50/100
clear
builtin echo "Wait complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 60/100
clear
builtin echo "Reload complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 70/100
clear
builtin echo "Creating files..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 80/100
clear
builtin echo "Executing diagram..."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 90/100
clear
builtin echo "Almost complete."
incrementar_progreso 10 # Incrementa el progreso en 10% | Status actual 100/100
clear
builtin echo "Installation complete."
exit 1 # Codigo de salida 1 - Apoyo de Nisamov github