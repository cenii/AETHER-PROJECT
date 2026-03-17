# 🛡️ Proyecto AETHER: Sistema de Defensa y Engaño Impulsado por IA

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white)](https://www.cloudflare.com/)
[![Wazuh](https://img.shields.io/badge/Wazuh-00A9E0?style=for-the-badge&logo=wazuh&logoColor=white)](https://wazuh.com/)

AETHER es un ecosistema de ciberseguridad proactiva desplegado en **Oracle Cloud (OCI)**. Combina **Honeypots (Señuelos)**, **SIEM (Wazuh)** e **IA Generativa** para automatizar la detección y mitigación de amenazas.

## 🚀 Características Principales
- **Gestión Sigilosa:** Entrada de exposición cero a través de **Túneles de Cloudflare**.
- **Engaño Activo:** Honeypot SSH en tiempo real (Cowrie) en el puerto 22.
- **Respuesta Automatizada:** Baneo a nivel de kernel mediante **iptables** activado por Wazuh.
- **Análisis con IA:** Análisis semántico de logs usando **OpenRouter (LLMs)** para la atribución de amenazas.

## 🏗️ Arquitectura
![Arquitectura AETHER](./assets/esquema.png)

## 🛠️ Stack Tecnológico
- **Infraestructura:** Oracle Cloud (Instancia Ubuntu).
- **Orquestación:** Portainer y Docker.
- **Inteligencia:** n8n + Modelos de IA (GPT-4o/Claude).

## 🚀 Instrucciones de Despliegue (Deployment Guide)

Sigue estos pasos para poner en marcha el ecosistema **AETHER** en una instancia de Ubuntu (optimizado para Oracle Cloud OCI).

### 1. Configuración de Seguridad del Host (Paso Crítico)
Para que el Honeypot funcione en el puerto 22, primero debemos mover el servicio SSH real del servidor.

1. **Cambiar el puerto SSH:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   Modifica la línea `Port 22` por `Port 1022`.
2. **Reiniciar el servicio SSH:**
   ```bash
   sudo systemctl restart ssh
   ```
   *Nota: Asegúrate de tener abierto el puerto 1022 en la VCN de Oracle Cloud antes de cerrar tu sesión actual.*

---

### 2. Instalación de Requisitos
Actualiza el sistema e instala Docker y Docker Compose si no los tienes:
```bash
sudo apt update && sudo apt install docker.io docker-compose -y
sudo systemctl enable --now docker
```

### 3. Configuración del Proyecto
Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/aether-project.git
cd aether-project
```

Rellena los campos obligatorios:
- `CF_TUNNEL_TOKEN`: Tu token de Cloudflare Zero Trust.

### 4. Lanzamiento de la Infraestructura
Despliega todos los contenedores mediante Portainer o directamente por terminal:
```bash
docker-compose up -d
```
Esto levantará el stack completo: Wazuh (Manager, Indexer, Dashboard), Cowrie Honeypot, n8n y Cloudflared.

### 5. Configuración Post-Despliegue

#### A. Aplicar Reglas de Wazuh
Copia las reglas personalizadas al volumen del manager:
```bash
cp wazuh/local_rules.xml /var/lib/docker/volumes/aether-project_wazuh_etc_rules/_data/local_rules.xml
docker restart wazuh-manager
```

#### B. Importar Workflow en n8n
1. Accede a n8n a través de tu túnel de Cloudflare.
2. Ve a **Settings > Import Workflow** y selecciona `n8n/workflow-aether-soc.json`.
3. Activa el nodo de Webhook y el flujo.

#### C. Ejecutar AETHER-Guard (Script de Baneo)
Inicia el script de monitorización en segundo plano:
```bash
chmod +x scripts/ban-hacker.sh
sudo ./scripts/ban-hacker.sh &
```

**[Opcional] Verificar y Monitorear:**
Verificar que el baneo funciona:
```bash
tail -f /var/ossec/logs/active-responses.log
```
Ver las IPs bloqueadas actualmente:
```bash
sudo iptables -t raw -L -n
```
