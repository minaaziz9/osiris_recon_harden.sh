# Enhanced System Recon and Hardening Script

This script performs basic system reconnaissance, network vulnerability scanning, and provides hardening suggestions on Linux servers. It integrates **Nmap** for advanced network scanning and **Metasploit** for targeted vulnerability assessments.

## Features
- Basic system reconnaissance (open ports, active users, running services)
- Nmap scanning (detailed network recon and vulnerability checks)
- Metasploit scanning (specific vulnerability detection)
- Hardening recommendations based on system state
- Log file output for easy review

## Requirements
- **Nmap** installed (`sudo apt install nmap`)
- **Metasploit** installed (`sudo apt install metasploit-framework`)

## Usage
1. **Make the script executable**:
   ```bash
   chmod +x enhanced_recon_harden.sh
