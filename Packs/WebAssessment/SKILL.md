---
name: WebAssessment
description: Web application security testing — OWASP Top 10, content discovery, parameter fuzzing, injection testing, authentication bypass, business logic flaws, and threat modeling
---

# Web Assessment Pack

Comprehensive web application penetration testing. Covers the OWASP Top 10, business logic testing, API security, and advanced vulnerability classes.

## Capabilities

- **Content Discovery** — Directory brute-forcing, file enumeration, hidden endpoint discovery
- **Parameter Fuzzing** — GET/POST parameter discovery, value fuzzing, injection point identification
- **Injection Testing** — SQL injection, XSS, command injection, SSTI, SSRF, XXE, LDAP injection
- **Authentication Testing** — Brute force, credential stuffing, session management, MFA bypass
- **Authorization Testing** — IDOR, privilege escalation, horizontal/vertical access control
- **Business Logic** — Workflow bypass, race conditions, price manipulation, feature abuse
- **API Security** — REST/GraphQL testing, mass assignment, broken object-level auth
- **Threat Modeling** — STRIDE-based threat identification and risk assessment

## Tools

| Tool | Purpose | Install |
|------|---------|---------|
| ffuf | Fast web fuzzer | `go install github.com/ffuf/ffuf/v2@latest` |
| nuclei | Template-based vuln scanner | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| sqlmap | SQL injection automation | `apt install sqlmap` |
| dalfox | XSS scanner | `go install github.com/hahwul/dalfox/v2@latest` |
| nikto | Web server scanner | `apt install nikto` |
| arjun | Parameter discovery | `pip install arjun` |
| commix | Command injection | `apt install commix` |
| wpscan | WordPress scanner | `gem install wpscan` |
| feroxbuster | Recursive content discovery | `apt install feroxbuster` |
| gobuster | Directory/DNS brute-forcing | `apt install gobuster` |

## Workflows

| Workflow | When to Use |
|----------|-------------|
| [MasterMethodology](Workflows/MasterMethodology.md) | Full web application pentest (comprehensive) |
| [FuzzingGuide](Workflows/FuzzingGuide.md) | Content discovery and parameter fuzzing |
| [BugBountyHunting](Workflows/BugBountyHunting.md) | Bug bounty target assessment |
| [ThreatModel](Workflows/ThreatModel.md) | STRIDE-based threat modeling |

## Quick Start

```bash
# Content discovery
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403

# Vulnerability scanning
nuclei -u https://target.com -as -t cves/ -t vulnerabilities/ -o nuclei_results.txt

# SQL injection testing
sqlmap -u "https://target.com/api/search?q=test" --batch --risk 2 --level 3

# XSS scanning
echo "https://target.com/search?q=FUZZ" | dalfox pipe
```
