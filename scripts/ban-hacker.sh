#!/bin/bash

# =================================================================
# PROJECT AETHER - Active Response Script
# Author: Hugo Ceniceros (hugoceniceros.com)
# Description: Monitors Wazuh active-responses.log and bans IPs 
#              using iptables (RAW table for maximum efficiency).
# =================================================================

# --- CONFIGURACIÓN ---
LOG_FILE="/var/ossec/logs/active-responses.log"
WHITELIST=("127.0.0.1" "TU_IP_PUBLICA_AQUI") # Añade aquí tu IP de casa/oficina
BAN_TIME=600 # Tiempo de baneo en segundos (10 min)

# --- COLORES PARA TERMINAL ---
RED='\033[0.31m'
GREEN='\033[0.32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+] AETHER-Guard iniciado. Vigilando el perímetro...${NC}"

# --- FUNCIÓN DE BANEO ---
ban_ip() {
    local IP=$1
    
    # Comprobar si la IP está en la Whitelist
    for white_ip in "${WHITELIST[@]}"; do
        if [ "$IP" == "$white_ip" ]; then
            echo -e "${GREEN}[!] Intento de baneo ignorado: $IP está en la Whitelist.${NC}"
            return
        fi
    done

    echo -e "${RED}[!] ATENCIÓN: Baneando IP atacante: $IP${NC}"

    # 1. Bloqueo en la tabla RAW (Corta el tráfico antes de que llegue a Docker/Servicios)
    iptables -t raw -I PREROUTING -s "$IP" -j DROP
    
    # 2. Bloqueo específico para la cadena de Docker (Capa extra de seguridad)
    iptables -I DOCKER-USER -s "$IP" -j DROP

    # Programar el desbaneo automático
    (sleep $BAN_TIME && /usr/bin/iptables -t raw -D PREROUTING -s "$IP" -j DROP && /usr/bin/iptables -D DOCKER-USER -s "$IP" -j DROP && echo -e "${GREEN}[+] IP Liberada: $IP${NC}") &
}

# --- MONITORIZACIÓN EN TIEMPO REAL ---
# Buscamos patrones de 'add' en el log de Wazuh
tail -fn0 "$LOG_FILE" | while read -r line; do
    # Ejemplo de línea: "Tue Mar 17 12:00:01 CET 2026 /var/ossec/bin/active-response/bin/host-deny.sh add - 1.2.3.4 1710673201.1234 100002"
    if echo "$line" | grep -q "add"; then
        # Extraer la IP (es el 8º argumento en el formato estándar de Wazuh)
        IP_ATTACKER=$(echo "$line" | awk '{print $8}')
        
        if [[ $IP_ATTACKER =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            ban_ip "$IP_ATTACKER"
        fi
    fi
done