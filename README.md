# 🛡️ Project AETHER: AI-Driven Deception & Defense System

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white)](https://www.cloudflare.com/)
[![Wazuh](https://img.shields.io/badge/Wazuh-00A9E0?style=for-the-badge&logo=wazuh&logoColor=white)](https://wazuh.com/)

AETHER is a proactive cybersecurity ecosystem deployed on **Oracle Cloud (OCI)**. It combines **Honey-Potting**, **SIEM (Wazuh)**, and **Generative AI** to automate threat detection and mitigation.

## 🚀 Key Features
- **Stealth Management:** Zero-exposure entry via **Cloudflare Tunnels**.
- **Active Deception:** Real-time SSH honeypot (Cowrie) on port 22.
- **Automated Response:** Kernel-level banning via **iptables** triggered by Wazuh.
- **AI Analytics:** Semantic log analysis using **OpenRouter (LLMs)** for threat attribution.

## 🏗️ Architecture
![Arquitectura AETHER](./assets/esquema.png)

## 🛠️ Stack
- **Infrastructure:** Oracle Cloud (Ubuntu Instance).
- **Orchestration:** Portainer & Docker.
- **Intelligence:** n8n + AI Models (GPT-4o/Claude).
