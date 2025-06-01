#!/usr/bin/env bash
#
# usb_artifact_collector.sh
# Recopila artefactos de dispositivos USB conectados: salida de lsusb y registros de kernel en dmesg.
#
# Uso: sudo ./usb_artifact_collector.sh <directorio_destino>
#

# Validar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 <directorio_destino>"
    exit 1
fi

OUTPUT_DIR="$1"

# Verificar que sea ruta válida (si no existe, crearla)
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo crear '$OUTPUT_DIR'."
        exit 1
    fi
fi

# 1) Registrar lsusb completo
echo "Obteniendo salida de lsusb..."
lsusb > "${OUTPUT_DIR}/lsusb_$(date +%F_%H-%M-%S).txt"

# 2) Registrar dmesg filtrado por USB (últimas 200 líneas)
echo "Obteniendo últimos mensajes de dmesg relacionados con USB..."
dmesg | grep -i usb | tail -n 200 > "${OUTPUT_DIR}/dmesg_usb_$(date +%F_%H-%M-%S).txt"

# 3) Lista de dispositivos USB en /sys/bus/usb/devices
echo "Listando directorios en /sys/bus/usb/devices..."
ls -l /sys/bus/usb/devices > "${OUTPUT_DIR}/sys_usb_devices_$(date +%F_%H-%M-%S).txt"

echo "Reporte USB guardado en '$OUTPUT_DIR'."

