#!/bin/bash

# Output file
LOGFILE="recon_harden_log.txt"
echo "System Recon and Hardening Log" > $LOGFILE
echo "==============================" >> $LOGFILE

# Log and display function
log() {
    echo "$1" | tee -a $LOGFILE
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to list open ports (basic recon)
check_open_ports() {
    log "Open Ports:"
    ss -tuln | grep LISTEN | tee -a $LOGFILE
    log "------------------------------"
}

# Function to list active users
check_active_users() {
    log "Active Users:"
    who | tee -a $LOGFILE
    log "------------------------------"
}

# Function to list running services
check_running_services() {
    log "Running Services:"
    systemctl list-units --type=service --state=running | tee -a $LOGFILE
    log "------------------------------"
}

# Check if the firewall is active
check_firewall() {
    log "Firewall Status:"
    ufw status | grep -q "inactive" && log "Firewall is inactive" || log "Firewall is active"
    log "------------------------------"
}

# Check for world-writable files
check_world_writable() {
    log "World-Writable Files:"
    find / -type f -perm -o+w -exec ls -l {} \; 2>/dev/null | tee -a $LOGFILE
    log "------------------------------"
}

# Suggest enabling firewall
suggest_firewall() {
    ufw status | grep -q "inactive" && log "Suggestion: Enable the firewall using 'ufw enable'" || log "Firewall is already enabled."
}

# Suggest disabling root login over SSH
suggest_ssh_hardening() {
    grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config && log "Suggestion: Disable root login over SSH in /etc/ssh/sshd_config" || log "Root login over SSH is already disabled."
}

# Nmap Scan Function
run_nmap_scan() {
    log "Starting Nmap Scan..."
    echo "Enter target IP or network range (e.g., 192.168.1.0/24):"
    read target

    # Run a general Nmap scan
    nmap -A -sV "$target" -oN nmap_scan_results.txt | tee -a $LOGFILE
    log "Nmap scan complete. Results saved to nmap_scan_results.txt."
}

# Nmap Vulnerability Scan
run_nmap_vuln_scan() {
    log "Starting Nmap Vulnerability Scan..."
    echo "Enter target IP or network range (e.g., 192.168.1.0/24):"
    read target

    # Run Nmap vulnerability scan
    nmap --script vuln "$target" -oN nmap_vuln_results.txt | tee -a $LOGFILE
    log "Vulnerability scan complete. Results saved to nmap_vuln_results.txt."
}

# Metasploit Scan Function
run_metasploit_scan() {
    log "Starting Metasploit Vulnerability Scan..."
    echo "Enter target IP:"
    read target

    # Create a resource script for Metasploit
    echo "use auxiliary/scanner/portscan/tcp" > metasploit_scan.rc
    echo "set RHOSTS $target" >> metasploit_scan.rc
    echo "set PORTS 80,443,445" >> metasploit_scan.rc
    echo "run" >> metasploit_scan.rc
    echo "exit" >> metasploit_scan.rc

    # Run Metasploit with the resource script
    msfconsole -r metasploit_scan.rc | tee -a $LOGFILE
    log "Metasploit scan complete. Results are logged above."
    rm metasploit_scan.rc
}

# Main function to execute all checks and scans
run_all_checks() {
    log "Starting System Recon and Hardening..."
    
    # Basic Recon Functions
    check_open_ports
    check_active_users
    check_running_services
    check_firewall
    check_world_writable

    # Hardening Suggestions
    suggest_firewall
    suggest_ssh_hardening

    # Nmap and Metasploit Scans
    run_nmap_scan
    run_nmap_vuln_scan
    run_metasploit_scan
    
    log "System Recon and Hardening Complete."
}

run_all_checks
