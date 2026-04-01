# Passive Reconnaissance Workflow

OSINT-only reconnaissance without sending any traffic to the target. Useful for pre-engagement intelligence or when active scanning is not yet authorized.

## Prerequisites

- Target domain/organization confirmed
- API keys configured in `.env` (Shodan, Censys, SecurityTrails, VirusTotal)

## Phase 1: Domain Intelligence

### 1.1 WHOIS Information

```bash
whois $DOMAIN
# Record: registrar, creation date, expiry, nameservers, registrant org
```

### 1.2 DNS Records (Public Resolvers)

```bash
# All record types via public DNS
for type in A AAAA MX NS TXT SOA CNAME SRV; do
  dig $type $DOMAIN +short
done

# SPF/DMARC/DKIM records
dig TXT $DOMAIN +short
dig TXT _dmarc.$DOMAIN +short
```

### 1.3 Passive Subdomain Discovery

```bash
# subfinder (passive sources only, no brute force)
subfinder -d $DOMAIN -all -o passive_subs.txt

# Certificate Transparency
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sort -u >> passive_subs.txt

# SecurityTrails API
curl -s "https://api.securitytrails.com/v1/domain/$DOMAIN/subdomains" \
  -H "APIKEY: $SECURITYTRAILS_API_KEY" | jq -r '.subdomains[]' | sed "s/$/.${DOMAIN}/" >> passive_subs.txt

sort -u passive_subs.txt -o passive_subs.txt
```

## Phase 2: Infrastructure Intelligence

### 2.1 Shodan Queries

```bash
# Search by hostname
curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=hostname:$DOMAIN"

# Search by SSL cert
curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=ssl.cert.subject.cn:$DOMAIN"

# Search by organization
curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=org:\"$ORG_NAME\""
```

### 2.2 Censys Queries

```bash
# Search certificates
curl -s "https://search.censys.io/api/v2/certificates/search" \
  -H "Authorization: Basic $(echo -n "$CENSYS_API_ID:$CENSYS_API_SECRET" | base64)" \
  -d '{"q": "'$DOMAIN'", "per_page": 100}'
```

### 2.3 VirusTotal

```bash
# Domain report
curl -s "https://www.virustotal.com/api/v3/domains/$DOMAIN" \
  -H "x-apikey: $VIRUSTOTAL_API_KEY" | jq '.data.attributes'

# Subdomains
curl -s "https://www.virustotal.com/api/v3/domains/$DOMAIN/subdomains" \
  -H "x-apikey: $VIRUSTOTAL_API_KEY" | jq -r '.data[].id'
```

## Phase 3: Web Archive Intelligence

### 3.1 Historical URLs

```bash
# Wayback Machine URLs
echo $DOMAIN | waybackurls > wayback_urls.txt

# Filter for interesting files
grep -iE "\.(json|xml|yaml|yml|conf|cfg|env|bak|sql|log|txt|zip|tar|gz)$" wayback_urls.txt > interesting_files.txt

# Find old API endpoints
grep -iE "/api/|/v[0-9]/|/graphql|/rest/" wayback_urls.txt > api_endpoints.txt

# Google dorking (manual or via search API)
# site:$DOMAIN filetype:pdf
# site:$DOMAIN inurl:admin
# site:$DOMAIN intitle:"index of"
```

### 3.2 GitHub/Code Repository Search

```bash
# Search GitHub for domain references
# Look for: API keys, credentials, internal URLs, configuration files
# Use GitHub search: "example.com" password OR secret OR key OR token
```

## Phase 4: Email Intelligence

### 4.1 Email Harvesting

```bash
# theHarvester
theHarvester -d $DOMAIN -b all -l 500 -f harvester_results

# Hunter.io API
curl -s "https://api.hunter.io/v2/domain-search?domain=$DOMAIN&api_key=$HUNTER_API_KEY" | \
  jq -r '.data.emails[].value'
```

### 4.2 Email Verification

```bash
# Check if email addresses exist (passive — MX record check only)
# Verify MX records exist
dig MX $DOMAIN +short
```

## Phase 5: Technology Profiling

### 5.1 Without Touching Target

```bash
# Check BuiltWith/Wappalyzer data via APIs
# Shodan already provides technology data

# DNS-based CDN/hosting detection
dig A $DOMAIN +short
# Cross-reference IPs with known CDN ranges (Cloudflare, AWS, etc.)

# Check for known technology indicators in DNS
dig TXT $DOMAIN +short  # Often reveals Google Workspace, Office 365, etc.
```

## Phase 6: Consolidation

Compile all passive intelligence into a summary:

1. **Organization details** — WHOIS registrant, creation date, hosting provider
2. **Subdomains discovered** — count and notable ones
3. **Infrastructure** — IP ranges, ASN, CDN, cloud providers
4. **Technologies** — detected via Shodan/DNS/archives
5. **Email addresses** — harvested addresses and patterns
6. **Interesting URLs** — from web archives
7. **Exposed secrets** — from code repositories or archives
8. **Attack surface estimate** — based on findings

Log all findings to `Ops/findings.jsonl`.
