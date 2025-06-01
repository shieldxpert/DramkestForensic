#!/usr/bin/env bash
#
# DramkestForensic.sh
# Script principal del toolkit DramkestForensic.
# Al arrancar, comprueba e instala (en silencio) las dependencias básicas si faltan:
#   - exiftool
#   - tcpdump
#   - dos2unix
#   - binutils (strings)
#   - file
#   - wget
# Luego muestra un menú para ejecutar cada utilidad y vuelca el informe de salida
# (stdout) a un archivo en ~/Downloads, sin pedir ruta al usuario.
#
# Creado por Shieldxpert el 2025-06-xx (banner actualizado)
#

# ===============================
# 0) Función: instalar dependencias en silencio
# ===============================
install_deps_silently() {
  REQUIRED_CMDS=(exiftool tcpdump dos2unix strings file wget)
  MISSING=()

  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      MISSING+=("$cmd")
    fi
  done

  # Si no faltan, salir
  if [ "${#MISSING[@]}" -eq 0 ]; then
    return 0
  fi

  # Necesitamos privilegios root para instalar
  if [ "$EUID" -ne 0 ]; then
    sudo bash -c "'"$(printf '%s\n' "$(declare -f install_deps_silently)"; echo 'install_deps_silently')"'"
    return $?
  fi

  # Ya somos root: detectamos gestor de paquetes
  if command -v apt-get &>/dev/null; then
    apt-get update -qq >/dev/null 2>&1
    PKGS=()
    for c in "${MISSING[@]}"; do
      case "$c" in
        exiftool)   PKGS+=("exiftool") ;;
        tcpdump)    PKGS+=("tcpdump") ;;
        dos2unix)   PKGS+=("dos2unix") ;;
        strings)    PKGS+=("binutils") ;;
        file)       PKGS+=("file") ;;
        wget)       PKGS+=("wget") ;;
      esac
    done
    apt-get install -y -qq "${PKGS[@]}" >/dev/null 2>&1

  elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    if command -v dnf &>/dev/null; then
      PM="dnf"
    else
      PM="yum"
      $PM install -y -q epel-release >/dev/null 2>&1
    fi

    PKGS=()
    for c in "${MISSING[@]}"; do
      case "$c" in
        exiftool)   PKGS+=("perl-Image-ExifTool") ;;
        tcpdump)    PKGS+=("tcpdump") ;;
        dos2unix)   PKGS+=("dos2unix") ;;
        strings)    PKGS+=("binutils") ;;
        file)       PKGS+=("file") ;;
        wget)       PKGS+=("wget") ;;
      esac
    done
    $PM install -y -q "${PKGS[@]}" >/dev/null 2>&1

  else
    echo "No se detectó gestor apt ni yum/dnf. Instala manualmente: ${MISSING[*]}"
    return 1
  fi

  return 0
}

# Llamada inicial para que instale dependencias (en silencio)
install_deps_silently

# ===============================
# 1) Banner ASCII personalizado
# ===============================
echo "╭━━━╮╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╭╮╭━━━╮"
echo "╰╮╭╮┃╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╭╯╰┫╭━━╯"
echo "╱┃┃┃┣━┳━━┳╮╭┫┃╭┳━━┳━┻╮╭┫╰━━┳━━┳━┳━━┳━╮╭━━┳┳━━╮"
echo "╱┃┃┃┃╭┫╭╮┃╰╯┃╰╯┫┃━┫━━┫┃┃╭━━┫╭╮┃╭┫┃━┫╭╮┫━━╋┫╭━╯"
echo "╭╯╰╯┃┃┃╭╮┃┃┃┃╭╮┫┃━╋━━┃╰┫┃╱╱┃╰╯┃┃┃┃━┫┃┃┣━━┃┃╰━╮"
echo "╰━━━┻╯╰╯╰┻┻┻┻╯╰┻━━┻━━┻━┻╯╱╱╰━━┻╯╰━━┻╯╰┻━━┻┻━━╯"
echo

# ===============================
# 2) Verificar scripts auxiliares – existencia y permisos
# ===============================
declare -a REQUIRED_SCRIPTS=(
  "metadata_extractor.sh"
  "file_signature_checker.sh"
  "usb_artifact_collector.sh"
  "network_capture_collector.sh"
  "simple_hash_evidence.sh"
  "slack_space_analyzer.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -x "$script" ]; then
    echo "Error: No se encontró o no tiene permiso de ejecución '$script'."
    echo "Por favor verifica y corre: chmod +x $script"
    exit 1
  fi
done
echo

# ===============================
# 3) Menú interactivo + informes automáticos en ~/Downloads
# ===============================
DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"

echo "Selecciona la utilidad forense que deseas ejecutar:"
PS3="Ingresa el número de tu opción (o '7' para salir): "

options=(
  "Metadata Extractor"
  "File Signature Checker"
  "USB Artifact Collector"
  "Network Capture Collector"
  "Simple Hash Evidence"
  "Slack Space Analyzer"
  "Salir"
)

select opt in "${options[@]}"; do
  ts=$(date +%Y%m%d_%H%M%S)
  case $REPLY in
    1)
      read -rp "Directorio a escanear (para extraer metadatos): " dir
      report="$DOWNLOAD_DIR/metadata_extractor_$ts.txt"
      echo "Generando informe Metadata Extractor → '$report'..."
      echo "-----------------------------------------------------------"
      ./metadata_extractor.sh "$dir" > "$report"
      echo "Informe guardado en: $report"
      echo "-----------------------------------------------------------"
      break
      ;;
    2)
      read -rp "Directorio o archivo a verificar (extensión vs firma): " dir2
      report="$DOWNLOAD_DIR/file_signature_checker_$ts.txt"
      echo "Generando informe File Signature Checker → '$report'..."
      echo "-----------------------------------------------------------"
      ./file_signature_checker.sh "$dir2" > "$report"
      echo "Informe guardado en: $report"
      echo "-----------------------------------------------------------"
      break
      ;;
    3)
      outdir="$DOWNLOAD_DIR/usb_artifacts_$ts"
      mkdir -p "$outdir"
      report="$DOWNLOAD_DIR/usb_artifact_report_$ts.txt"
      echo "Ejecutando USB Artifact Collector (artefactos → '$outdir')..."
      echo "Generando informe → '$report'..."
      echo "-----------------------------------------------------------"
      ./usb_artifact_collector.sh "$outdir" > "$report"
      echo "Informe guardado en: $report"
      echo "Artefactos USB en: $outdir"
      echo "-----------------------------------------------------------"
      break
      ;;
    4)
      read -rp "Interfaz de red a capturar (ej: eth0, wlan0): " iface
      read -rp "Duración en segundos (ej: 60): " dur
      pcapfile="$DOWNLOAD_DIR/network_capture_$ts.pcap"
      report="$DOWNLOAD_DIR/network_capture_report_$ts.txt"
      echo "Ejecutando Network Capture Collector (pcap → '$pcapfile')..."
      echo "Generando informe → '$report'..."
      echo "-----------------------------------------------------------"
      sudo ./network_capture_collector.sh "$iface" "$dur" "$pcapfile" > "$report"
      echo "Informe guardado en: $report"
      echo "Archivo pcap guardado en: $pcapfile"
      echo "-----------------------------------------------------------"
      break
      ;;
    5)
      read -rp "Directorio con evidencia a hashear: " dir5
      report="$DOWNLOAD_DIR/simple_hash_evidence_$ts.txt"
      echo "Generando informe Simple Hash Evidence → '$report'..."
      echo "-----------------------------------------------------------"
      ./simple_hash_evidence.sh "$dir5" > "$report"
      echo "Informe guardado en: $report"
      echo "-----------------------------------------------------------"
      break
      ;;
    6)
      read -rp "Dispositivo/imagen a analizar (ej: /dev/sda1 o /ruta/imagen.dd): " dev6
      slackout="$DOWNLOAD_DIR/slack_strings_$ts.txt"
      report="$DOWNLOAD_DIR/slack_space_report_$ts.txt"
      echo "Ejecutando Slack Space Analyzer (cadenas → '$slackout')..."
      echo "Generando informe → '$report'..."
      echo "-----------------------------------------------------------"
      sudo ./slack_space_analyzer.sh "$dev6" "$slackout" > "$report"
      echo "Informe guardado en: $report"
      echo "Cadenas extraídas en: $slackout"
      echo "-----------------------------------------------------------"
      break
      ;;
    7)
      echo "Saliendo. ¡Hasta luego!"
      exit 0
      ;;
    *)
      echo "Opción inválida. Intenta de nuevo."
      ;;
  esac
done

exit 0




