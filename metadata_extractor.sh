#!/usr/bin/env bash
#
# metadata_extractor.sh
# Recorre un directorio y extrae metadatos (EXIF, propiedades de documentos, etc.)
# usando exiftool. Genera un CSV de salida con la ruta de cada archivo y sus metadatos.
#
# Uso: ./metadata_extractor.sh <directorio>
#

# Verificar que exiftool esté instalado
if ! command -v exiftool &>/dev/null; then
    echo "Error: exiftool no está instalado. Instálalo con 'sudo apt install exiftool' o similar."
    exit 1
fi

# Validar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' no existe o no es un directorio."
    exit 1
fi

# Cabecera CSV
echo "ruta_archivo,metadatos"

# Recorrer cada archivo recursivamente
find "$TARGET_DIR" -type f | while IFS= read -r file; do
    # Extraer metadatos resumidos (solo los más relevantes)
    # Formato: campo1="valor1"|campo2="valor2"|...
    METAS=$(exiftool -s -s -s -All:All "$file" 2>/dev/null | \
            awk -F': ' '{ printf "%s=\"%s\"|", $1, $2 }' | sed 's/|$//')

    # Si no hay metadatos, poner "NA"
    if [ -z "$METAS" ]; then
        METAS="NA"
    fi

    # Imprimir línea CSV (escapando comas internas)
    ESCAPED_PATH=$(printf '%s' "$file" | sed 's/,/\\,/g')
    ESCAPED_METAS=$(printf '%s' "$METAS" | sed 's/,/\\,/g')

    echo "$ESCAPED_PATH,$ESCAPED_METAS"
done

