# Network Reconnaissance Workflow

IP range, CIDR block, and network-level scanning methodology.

## Prerequisites

- Target IP ranges confirmed in `Ops/scope.json`
- Tools: nmap, masscan, dnsx, whois

## Phase 1: Network Mapping

### 1.1 WHOIS and ASN Lookup

```bash
# WHOIS for IP ownership
whois $TARGET_IP

# ASN lookup
whois -h whois.radb.net -- "-i origin AS$ASN"

# Resolve ASN from IP
curl -s "https://api.bgpview.io/ip/$TARGET_IP" | jq '.data.prefixes[].asn'

# Get all prefixes for ASN
curl -s "https://api.bgpview.io/asn/$ASN/prefixes" | jq -r '.data.ipv4_prefixes[].prefix'
```

### 1.2 Reverse DNS

```bash
# Reverse DNS on CIDR range
dnsx -l <(prips $CIDR) -ptr -resp-only -o rdns.txt

# Nmap reverse DNS
nmap -sL $CIDR | grep "report for" | awk '{print $5, $6}'
```

## Phase 2: Host Discovery

### 2.1 Ping Sweep

```bash
# ICMP ping sweep
nmap -sn $CIDR -oA host_discovery

# ARP scan (if on same network segment)
nmap -PR -sn $CIDR -oA arp_scan

# TCP SYN ping on common ports (bypasses ICMP filtering)
nmap -sn -PS80,443,22,21,25,3389 $CIDR -oA tcp_ping
```

### 2.2 Extract Live Hosts

```bash
grep "Up" host_discovery.gnmap | awk '{print $2}' > live_hosts.txt
wc -l live_hosts.txt
```

## Phase 3: Port Scanning

### 3.1 Fast Port Scan with masscan

```bash
# masscan full port scan (fast but noisy)
masscan -p1-65535 --rate 10000 -iL live_hosts.txt -oJ masscan_results.json

# Extract open ports
cat masscan_results.json | jq -r '.[] | "\(.ip):\(.ports[].port)"' | sort -u
```

### 3.2 Detailed nmap Scan

```bash
# Service version detection on discovered ports
nmap -sV -sC -p$(cat masscan_results.json | jq -r '.[] | .ports[].port' | sort -un | tr '\n' ',') \
  -iL live_hosts.txt -oA nmap_detailed

# OS fingerprinting
nmap -O -iL live_hosts.txt -oA nmap_os

# Full scan with scripts
nmap -sV -sC -A -p- -T3 -iL live_hosts.txt -oA nmap_comprehensive
```

### 3.3 UDP Scanning

```bash
# Top 100 UDP ports
nmap -sU --top-ports 100 -T4 -iL live_hosts.txt -oA nmap_udp

# Common UDP services
nmap -sU -p 53,67,68,69,123,161,162,500,514,520,1900,5353 -iL live_hosts.txt -oA nmap_udp_common
```

## Phase 4: Service Enumeration

### 4.1 Per-Service Scripts

```bash
# SSH
nmap --script ssh-auth-methods,ssh2-enum-algos -p 22 -iL live_hosts.txt -oA nmap_ssh

# SMB
nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-vuln-* -p 445 -iL live_hosts.txt -oA nmap_smb

# SNMP
nmap --script snmp-info,snmp-brute -p 161 -sU -iL live_hosts.txt -oA nmap_snmp

# DNS
nmap --script dns-zone-transfer,dns-brute -p 53 -iL live_hosts.txt -oA nmap_dns

# LDAP
nmap --script ldap-rootdse,ldap-search -p 389,636 -iL live_hosts.txt -oA nmap_ldap

# RDP
nmap --script rdp-enum-encryption,rdp-vuln-ms12-020 -p 3389 -iL live_hosts.txt -oA nmap_rdp

# Database services
nmap --script ms-sql-info,mysql-info -p 1433,3306,5432,27017,6379 -iL live_hosts.txt -oA nmap_db
```

### 4.2 Banner Grabbing

```bash
# Netcat banner grab
while read host; do
  for port in 21 22 25 80 110 143 443 993 995; do
    echo "" | nc -w 3 $host $port 2>/dev/null | head -1
  done
done < live_hosts.txt | tee banners.txt
```

## Phase 5: Consolidation

### 5.1 Produce Summary

- Total live hosts
- Open ports by frequency
- Services by type (web, ssh, smb, database, etc.)
- OS distribution
- Notable findings (default creds, exposed services, vulns detected by NSE)

### 5.2 Log Findings

Log to `Ops/findings.jsonl`:
- Exposed database ports → high
- SMB shares with anonymous access → high
- Default SNMP communities → medium
- Outdated service versions → medium
- Open management interfaces (IPMI, iLO) → high
