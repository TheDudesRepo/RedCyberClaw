---
name: Recon
description: Attack surface discovery — subdomain enumeration, DNS resolution, port scanning, service fingerprinting, certificate transparency, and technology detection
---

# Recon Pack

Comprehensive reconnaissance and attack surface mapping. This pack covers passive and active information gathering to build a complete picture of the target's external footprint.

## Capabilities

- **Subdomain Enumeration** — Discover all subdomains via DNS brute-force, certificate transparency logs, web archives, and API sources
- **DNS Analysis** — Resolve records, identify DNS misconfigurations, zone transfer attempts, DNSSEC validation
- **WHOIS & ASN Mapping** — Identify ownership, registrar info, IP ranges, and autonomous system relationships
- **Port Scanning** — TCP/UDP port discovery, service version detection, OS fingerprinting
- **Service Fingerprinting** — Banner grabbing, protocol identification, version enumeration
- **Certificate Transparency** — Monitor CT logs for new subdomain discovery
- **Technology Detection** — Identify web frameworks, CMS platforms, WAFs, CDNs, and server software

## Tools

| Tool | Purpose | Install |
|------|---------|---------|
| subfinder | Passive subdomain discovery | `go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` |
| amass | Active/passive subdomain enum | `go install github.com/owasp-amass/amass/v4/...@master` |
| httpx | HTTP probing and tech detection | `go install github.com/projectdiscovery/httpx/cmd/httpx@latest` |
| dnsx | Fast DNS resolution | `go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest` |
| nmap | Port scanning and service detection | `apt install nmap` |
| masscan | High-speed port scanning | `apt install masscan` |
| whatweb | Web technology fingerprinting | `apt install whatweb` |
| wafw00f | WAF detection | `pip install wafw00f` |
| katana | Web crawling | `go install github.com/projectdiscovery/katana/cmd/katana@latest` |
| gau | URL discovery from web archives | `go install github.com/lc/gau/v2/cmd/gau@latest` |
| waybackurls | Wayback Machine URL extraction | `go install github.com/tomnomnom/waybackurls@latest` |

## Workflows

| Workflow | When to Use |
|----------|-------------|
| [DomainRecon](Workflows/DomainRecon.md) | Full domain reconnaissance against a target domain |
| [NetworkRecon](Workflows/NetworkRecon.md) | IP range and network-level port scanning |
| [PassiveRecon](Workflows/PassiveRecon.md) | OSINT-only recon without touching the target |

## Data

| Reference | Description |
|-----------|-------------|
| [LOTLBinaries](Data/LOTLBinaries.md) | Living Off The Land binaries for post-discovery |

## Quick Start

```bash
# Basic subdomain enumeration
subfinder -d target.com -all -o subs.txt

# Probe live hosts
cat subs.txt | httpx -status-code -title -tech-detect -o live.txt

# Port scan live hosts
nmap -sV -sC -p- -iL live_ips.txt -oA nmap_full

# Technology fingerprinting
whatweb -i live.txt --log-json=tech.json
```

## Scope Check

Before running any recon tool, verify the target is in scope:
```
Read Ops/scope.json → Confirm target domain/IP is in in_scope → Proceed
```
