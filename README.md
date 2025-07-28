
![License](https://img.shields.io/badge/license-MIT-blue?style=flat)
![Version](https://img.shields.io/badge/version-v1.0-orange?style=flat)
![Status](https://img.shields.io/badge/status-active-success?style=flat)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?style=flat)
![Author](https://img.shields.io/badge/author-ShieldXpert-black?style=flat)

**DramkestForensic** es un **toolkit forense en Bash/CLI** creado por **Shieldxpert**. Proporciona un conjunto de utilidades que facilitan el análisis forense directamente desde la terminal, con generación automática de informes.

---

## Índice

1. [Descripción] 
2. [Estructura del repositorio]
3. [Funcionalidades] 
4. [Instalación de dependencias]
5. [Estructura del repositorio] 
6. [Licencia] MIT
7. [Contacto] https://www.linkedin.com/in/tom-seg-inf

---

## Descripción

DramkestForensic está diseñado para agilizar tareas forenses comunes en entornos Linux. Las herramientas incluidas permiten:

- Extraer metadatos de archivos (imágenes, documentos, etc.).  
- Verificar la integridad de extensiones frente a firmas internas.  
- Recopilar artefactos de dispositivos USB conectados.  
- Capturar tráfico de red en formato PCAP.  
- Calcular hashes (MD5, SHA1, SHA256) de archivos en lotes.  
- Analizar el slack space de dispositivos o imágenes y extraer cadenas ASCII.

Todas las utilidades se invocan desde un **menú interactivo**, y los informes se generan automáticamente en la carpeta de descargas.

---

Estructura del repositorio:

DramkestForensic/
├── DramkestForensic.sh
├── metadata_extractor.sh
├── file_signature_checker.sh
├── usb_artifact_collector.sh
├── network_capture_collector.sh
├── simple_hash_evidence.sh
├── slack_space_analyzer.sh
├── README.md
└── LICENSE MIT

## Funcionalidades

1. ### `DramkestForensic.sh`  
   - Script principal que despliega un menú interactivo.  
   - Comprueba en segundo plano e instala automáticamente (si no está presente) cada dependencia necesaria.  
   - Verifica que cada sub-script auxiliar exista y tenga permisos de ejecución.  
   - Genera informes en `~/Downloads` nombrados según la herramienta y un timestamp.

2. ### `metadata_extractor.sh`  
   - Extrae metadatos de archivos en un directorio.  
   - Salida en formato CSV con campos `ruta_archivo,metadatos`.

3. ### `file_signature_checker.sh`  
   - Verifica que la extensión de cada archivo coincida con su firma interna.  
   - Salida en formato CSV con columnas `Archivo, Extensión_esperada, Tipo_detectado, Resultado`.

4. ### `usb_artifact_collector.sh`  
   - Recopila artefactos de los dispositivos USB conectados.  
   - Guarda archivos de texto detallados por tipo de artefacto.

5. ### `network_capture_collector.sh`  
   - Captura paquetes de red en una interfaz durante un periodo determinado.  
   - Guarda el tráfico en un archivo PCAP.

6. ### `simple_hash_evidence.sh`  
   - Calcula hashes MD5, SHA1 y SHA256 de todos los archivos de un directorio de forma recursiva.  
   - Salida CSV con columnas `ruta_archivo,md5,sha1,sha256`.

7. ### `slack_space_analyzer.sh`  
   - Extrae cadenas ASCII del slack space de un dispositivo o imagen.  
   - Salida en archivo de texto.

---

## Instalación de dependencias

Al ejecutar **DramkestForensic.sh**, cualquier dependencia que no esté instalada se instalará automáticamente en segundo plano.  
Solo se requieren privilegios de sudo.

---

## Uso

### Ejecutar el script principal

1. Clona o descarga el repositorio.  
2. Navega al proyecto:
   ```bash
   cd DramkestForensic
   chmod +x *.sh
   ./DramkestForensic.sh
