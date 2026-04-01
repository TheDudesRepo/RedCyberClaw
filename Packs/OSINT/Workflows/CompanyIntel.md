# Company Intelligence Workflow

Methodology for mapping a company's digital footprint, personnel, and technology infrastructure.

## Prerequisites

- Target company name and primary domain
- Tools: theharvester, recon-ng, subfinder, whois

## Phase 1: Corporate Structure

### 1.1 Basic Company Information

```bash
# WHOIS for domain ownership
whois $COMPANY_DOMAIN

# Search for related domains
# Check registrant name/org/email across WHOIS databases
```

### 1.2 Public Filings

Research through:
- **SEC EDGAR** (if public US company) — 10-K, 10-Q, proxy statements
- **Companies House** (UK) — filing history, directors
- **State Secretary of State** — business registration, officers
- **Crunchbase / PitchBook** — funding, investors, acquisitions

### 1.3 Subsidiary and Acquisition Mapping

```
Track:
- Parent company
- Subsidiaries
- Recent acquisitions (may have legacy infrastructure)
- Joint ventures and partnerships
- Divested entities (may still share infrastructure)
```

## Phase 2: Personnel Discovery

### 2.1 Employee Enumeration

```bash
# Email harvesting
theHarvester -d $COMPANY_DOMAIN -b google,linkedin,bing -l 500

# Hunter.io domain search
curl -s "https://api.hunter.io/v2/domain-search?domain=$COMPANY_DOMAIN&api_key=$HUNTER_API_KEY&limit=100" | \
  jq -r '.data.emails[].value'

# LinkedIn employee search (manual)
# Search: "company:$COMPANY" on LinkedIn
# Focus on: IT, Security, DevOps, Engineering roles
```

### 2.2 Key Personnel Identification

Target roles that provide valuable intelligence:
- **CISO / Security Team** — understanding of security posture
- **DevOps / SRE** — infrastructure and tooling clues
- **Developers** — technology stack, repos, code style
- **System Administrators** — infrastructure details
- **Executives** — high-value social engineering targets (for awareness, not attack)

### 2.3 Email Pattern Detection

```bash
# Hunter.io reveals patterns: {first}.{last}@domain.com, {f}{last}@domain.com, etc.
curl -s "https://api.hunter.io/v2/domain-search?domain=$COMPANY_DOMAIN&api_key=$HUNTER_API_KEY" | \
  jq '.data.pattern'
```

## Phase 3: Technology Intelligence

### 3.1 Job Postings Analysis

Search job boards for technology mentions:
- Job postings reveal: frameworks, languages, cloud providers, databases, tools
- Example: "Experience with AWS, Kubernetes, PostgreSQL, React" → tech stack map

### 3.2 Code Repositories

```bash
# Search GitHub for company repos
# github.com/orgs/$COMPANY/repositories

# Search for leaked code or credentials
# GitHub search: "example.com" password OR secret OR api_key

# Check for exposed .env, config files, API keys in commit history
trufflehog github --org=$COMPANY_GITHUB_ORG
```

### 3.3 Technology Stack (Passive)

```bash
# Shodan for infrastructure
curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=org:\"$COMPANY_NAME\"" | \
  jq '.matches[] | {ip: .ip_str, port: .port, product: .product, os: .os}'

# BuiltWith / Wappalyzer data for web technologies
# DNS records reveal email/cloud providers
dig MX $COMPANY_DOMAIN +short  # Google Workspace, O365, etc.
dig TXT $COMPANY_DOMAIN +short  # SPF reveals email infrastructure
```

## Phase 4: Infrastructure Mapping

### 4.1 Domain Portfolio

```bash
# Reverse WHOIS — find other domains with same registrant
# SecurityTrails reverse DNS
curl -s "https://api.securitytrails.com/v1/domain/$COMPANY_DOMAIN/associated" \
  -H "APIKEY: $SECURITYTRAILS_API_KEY"

# Subdomain enumeration
subfinder -d $COMPANY_DOMAIN -all -o company_subs.txt
```

### 4.2 IP Infrastructure

```bash
# Map IP ranges
whois -h whois.radb.net -- "-i origin AS$COMPANY_ASN"

# Shodan search by org
# Censys search by organization
```

### 4.3 Cloud Presence

```bash
# Check for S3 buckets
# Format: $COMPANY, $COMPANY-dev, $COMPANY-staging, $COMPANY-backup, etc.

# Check for Azure blobs
# $COMPANY.blob.core.windows.net

# Check for GCP buckets
# storage.googleapis.com/$COMPANY
```

## Phase 5: Consolidation

Produce company intelligence report:

1. **Company Profile** — Name, industry, size, locations, structure
2. **Domain Portfolio** — All related domains and subdomains
3. **Infrastructure** — IP ranges, ASN, cloud providers, CDN
4. **Technology Stack** — Languages, frameworks, databases, tools
5. **Personnel** — Key employees, email patterns, role mapping
6. **Security Posture Indicators** — Bug bounty program, security team size, published policies
7. **Potential Attack Vectors** — Based on discovered infrastructure and technology
