#!/usr/bin/env bash
#
# file_signature_checker.sh
# Verifica si la extensión de cada archivo coincide con su firma interna (según 'file').
#
# Uso: ./file_signature_checker.sh <directorio_o_archivo>
#

# Validar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 <directorio_o_archivo>"
    exit 1
fi

TARGET="$1"

if [ -d "$TARGET" ]; then
    # Si es directorio, obtenemos todos los archivos dentro
    FILES=$(find "$TARGET" -type f)
elif [ -f "$TARGET" ]; then
    FILES="$TARGET"
else
    echo "Error: '$TARGET' no existe."
    exit 1
fi

# Función: obtener la extensión en minúsculas
get_extension() {
    local fname="$1"
    echo "${fname##*.}" | tr '[:upper:]' '[:lower:]'
}

# Recorrer cada archivo
echo "Archivo,Extensión Esperada,Tipo Detectado,Resultado"
for f in $FILES; do
    EXT="$(get_extension "$f")"
    # Obtener descripción completa de 'file'
    TYPE_DESC=$(file --brief --mime-type "$f")

    # Mapear algunas extensiones comunes a sus tipos MIME esperados (muy básico)
    case "$EXT" in
        jpg|jpeg) EXPECTED="image/jpeg" ;;
        png)      EXPECTED="image/png" ;;
        gif)      EXPECTED="image/gif" ;;
        pdf)      EXPECTED="application/pdf" ;;
        txt)      EXPECTED="text/plain" ;;
        docx)     EXPECTED="application/zip" ;; # docx es un zip internamente
        zip)      EXPECTED="application/zip" ;;
        mp3)      EXPECTED="audio/mpeg" ;;
        mp4)      EXPECTED="video/mp4" ;;
        sqlite)   EXPECTED="application/x-sqlite3" ;;
        *)        EXPECTED="desconocido" ;;
    esac

    STATUS="OK"
    if [ "$EXPECTED" != "desconocido" ] && [ "$EXPECTED" != "$TYPE_DESC" ]; then
        STATUS="DISCREPANCIA"
    fi

    # Imprimir en formato CSV
    ESC_PATH=$(printf '%s' "$f" | sed 's/,/\\,/g')
    echo "$ESC_PATH,$EXT,$TYPE_DESC,$STATUS"
done

