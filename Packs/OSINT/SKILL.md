---
name: OSINT
description: Open-source intelligence gathering for people, companies, and entities — social media profiling, email discovery, corporate structure mapping, and digital footprint analysis
---

# OSINT Pack

Intelligence gathering from publicly available sources. Covers people, companies, organizations, and digital entities.

## Capabilities

- **People Intelligence** — Social media profiling, email discovery, username enumeration, digital footprint mapping
- **Company Intelligence** — Corporate structure, employee discovery, technology stack, public filings, M&A history
- **Entity Research** — Organizations, government bodies, NGOs, threat actor groups
- **Email Discovery** — Harvesting, verification, breach checking
- **Username Enumeration** — Cross-platform account discovery

## Tools

| Tool | Purpose | Install |
|------|---------|---------|
| sherlock | Username enumeration across 300+ sites | `pip install sherlock-project` |
| holehe | Email account detection | `pip install holehe` |
| theharvester | Email and subdomain harvesting | `apt install theharvester` |
| recon-ng | OSINT framework with modules | `apt install recon-ng` |
| spiderfoot | Automated OSINT collection | `pip install spiderfoot` |

## Workflows

| Workflow | When to Use |
|----------|-------------|
| [PeopleLookup](Workflows/PeopleLookup.md) | Investigating a specific person |
| [CompanyIntel](Workflows/CompanyIntel.md) | Mapping a company's attack surface and personnel |

## Quick Start

```bash
# Username search across platforms
sherlock targetuser --output sherlock_results.txt

# Email account detection
holehe target@example.com

# Email harvesting for a domain
theHarvester -d example.com -b all -l 200
```
