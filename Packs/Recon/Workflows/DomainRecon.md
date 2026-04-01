# Domain Reconnaissance Workflow

Complete domain reconnaissance methodology for mapping the attack surface of a target domain.

## Prerequisites

- Target domain confirmed in `Ops/scope.json`
- Tools installed: subfinder, amass, httpx, dnsx, nmap, whatweb, wafw00f, katana, gau

## Phase 1: Passive Subdomain Discovery

### 1.1 Multi-Source Subdomain Enumeration

```bash
# subfinder — queries 40+ passive sources
subfinder -d $DOMAIN -all -recursive -o subfinder.txt

# amass passive mode
amass enum -passive -d $DOMAIN -o amass.txt

# Certificate Transparency logs
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sort -u > crt.txt

# Web archive URLs (extract unique hostnames)
echo $DOMAIN | gau --threads 5 | unfurl -u domains | sort -u > gau_domains.txt

# Wayback Machine
echo $DOMAIN | waybackurls | unfurl -u domains | sort -u > wayback_domains.txt
```

### 1.2 Merge and Deduplicate

```bash
cat subfinder.txt amass.txt crt.txt gau_domains.txt wayback_domains.txt | \
  sort -u | grep -E "\.$DOMAIN$" > all_subs.txt

wc -l all_subs.txt  # Report total count
```

## Phase 2: DNS Resolution

### 2.1 Resolve All Subdomains

```bash
# Fast DNS resolution
dnsx -l all_subs.txt -resp -a -aaaa -cname -mx -ns -txt -o dns_resolved.txt

# Extract live IPs
dnsx -l all_subs.txt -a -resp-only -o resolved_ips.txt
sort -u resolved_ips.txt > unique_ips.txt
```

### 2.2 Identify Interesting DNS Records

```bash
# Find CNAMEs (potential takeover targets)
dnsx -l all_subs.txt -cname -resp -o cnames.txt

# Check for dangling CNAMEs (subdomain takeover candidates)
grep -i "NXDOMAIN\|SERVFAIL\|not found" cnames.txt > potential_takeovers.txt

# Zone transfer attempts
for ns in $(dig NS $DOMAIN +short); do
  dig AXFR $DOMAIN @$ns
done

# Check for DNSSEC
dig DNSKEY $DOMAIN +short
```

## Phase 3: HTTP Probing

### 3.1 Probe Live Web Services

```bash
# httpx with full fingerprinting
cat all_subs.txt | httpx \
  -status-code -title -tech-detect -content-length \
  -follow-redirects -web-server -ip \
  -o httpx_results.txt

# Extract just live URLs
cat all_subs.txt | httpx -silent -o live_urls.txt
```

### 3.2 WAF Detection

```bash
# Check for WAF on live hosts
while read url; do
  wafw00f "$url"
done < live_urls.txt | tee waf_results.txt
```

## Phase 4: Port Scanning

### 4.1 Quick Scan

```bash
# Fast top-port scan
nmap -sV --top-ports 1000 -T4 -iL unique_ips.txt -oA nmap_quick
```

### 4.2 Full Port Scan

```bash
# Full TCP port scan (slower, comprehensive)
nmap -sV -sC -p- -T3 -iL unique_ips.txt -oA nmap_full

# UDP top ports
nmap -sU --top-ports 100 -T4 -iL unique_ips.txt -oA nmap_udp
```

### 4.3 Targeted Service Scans

```bash
# Extract specific service ports from nmap results
grep "open" nmap_full.gnmap | grep -oP '\d+/open/tcp//\w+' | sort -u

# Targeted nmap scripts for discovered services
nmap -sV --script=http-enum,http-headers,http-methods -p 80,443,8080,8443 -iL unique_ips.txt -oA nmap_http
nmap -sV --script=ssl-enum-ciphers,ssl-cert -p 443,8443 -iL unique_ips.txt -oA nmap_ssl
nmap -sV --script=smb-enum-shares,smb-os-discovery -p 445 -iL unique_ips.txt -oA nmap_smb
```

## Phase 5: Technology Fingerprinting

### 5.1 Web Technology Detection

```bash
# WhatWeb fingerprinting
whatweb -i live_urls.txt --log-json=whatweb.json -a 3

# httpx tech detection (already done in Phase 3, extract results)
grep "tech:" httpx_results.txt | sort -u
```

### 5.2 JavaScript Framework Detection

```bash
# Crawl for JS files
katana -list live_urls.txt -jc -d 2 -o crawled_urls.txt

# Extract JS files for analysis
grep "\.js$" crawled_urls.txt | sort -u > js_files.txt
```

## Phase 6: URL and Endpoint Discovery

### 6.1 Web Archive Mining

```bash
# Collect historical URLs
echo $DOMAIN | gau --threads 5 --blacklist png,jpg,gif,css,woff,svg --o gau_urls.txt

# Wayback Machine
echo $DOMAIN | waybackurls > wayback_urls.txt

# Merge and find interesting patterns
cat gau_urls.txt wayback_urls.txt | sort -u | \
  grep -iE "api|admin|login|upload|config|backup|debug|test|dev|staging" > interesting_urls.txt
```

### 6.2 Active Crawling

```bash
# Katana deep crawl
katana -list live_urls.txt -d 3 -jc -kf all -o katana_crawl.txt
```

## Phase 7: Consolidation

### 7.1 Generate Summary

Produce a summary that includes:

1. **Total subdomains discovered** — count from all_subs.txt
2. **Live web services** — count from live_urls.txt
3. **Unique IPs** — count from unique_ips.txt
4. **Open ports by service** — from nmap results
5. **Technologies detected** — from whatweb/httpx
6. **WAF presence** — from wafw00f
7. **Potential subdomain takeovers** — from potential_takeovers.txt
8. **Interesting endpoints** — from interesting_urls.txt

### 7.2 Log Findings

Log any discoveries to `Ops/findings.jsonl`:
- Subdomain takeover candidates → severity: high
- Exposed admin panels → severity: medium
- Information disclosure (server versions, stack traces) → severity: low
- Open database ports (3306, 5432, 27017) → severity: high
- Default credentials pages → severity: medium

### 7.3 Next Steps

Based on findings, recommend:
- **Web Assessment** for discovered web applications
- **Network-level testing** for non-HTTP services
- **Exploitation** research for identified vulnerabilities
