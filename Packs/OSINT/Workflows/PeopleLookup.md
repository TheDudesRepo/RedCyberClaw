# People Lookup Workflow

Methodology for investigating a specific individual using public sources.

## Prerequisites

- Target name, email, or username
- Tools: sherlock, holehe, theharvester

## Phase 1: Identity Mapping

### 1.1 Username Enumeration

```bash
# Search known username across 300+ platforms
sherlock $USERNAME --output sherlock_results.txt --print-found

# If only email is known, derive likely usernames
# e.g., john.doe@example.com → johndoe, john.doe, jdoe
```

### 1.2 Email Account Detection

```bash
# Check which services an email is registered on
holehe $EMAIL --only-used

# Check for email in breach databases (ethical/legal sources)
# haveibeenpwned.com API
curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/$EMAIL" \
  -H "hibp-api-key: $HIBP_KEY" -H "user-agent: RedCyberClaw"
```

### 1.3 Email Discovery

```bash
# If only name + company is known
# Hunter.io
curl -s "https://api.hunter.io/v2/email-finder?domain=$COMPANY_DOMAIN&first_name=$FIRST&last_name=$LAST&api_key=$HUNTER_API_KEY"

# theHarvester for the company domain
theHarvester -d $COMPANY_DOMAIN -b google,linkedin -l 100
```

## Phase 2: Social Media Profiling

### 2.1 Manual Platform Checks

Search these platforms using known identifiers:

- **LinkedIn** — Professional profile, job history, connections, endorsements
- **Twitter/X** — Public posts, interactions, technical interests
- **GitHub** — Code repos, contributions, email in commits
- **Reddit** — Post/comment history, interests, technical discussions
- **Stack Overflow** — Technical expertise, questions asked
- **Medium/Dev.to** — Blog posts, technical writing

### 2.2 GitHub Intelligence

```bash
# Check public repos for sensitive data
# Look for: .env files, API keys, configuration, internal URLs
# Check commit history for accidentally committed secrets

# Git commit email extraction
curl -s "https://api.github.com/users/$GITHUB_USER/events" | \
  jq -r '.[].payload.commits[]?.author.email' | sort -u
```

## Phase 3: Digital Footprint

### 3.1 Search Engine Dorking

```
"John Doe" site:linkedin.com
"john.doe@example.com"
"johndoe" site:github.com
"John Doe" filetype:pdf site:example.com
```

### 3.2 Public Records and Archives

- Conference speaker lists and presentations
- Patent filings
- Academic publications
- Court records (PACER, state courts)
- Business registrations (Secretary of State)
- Property records

## Phase 4: Consolidation

Produce a profile containing:

1. **Identity** — Full name, aliases, usernames
2. **Contact** — Email addresses, phone numbers (if public)
3. **Employment** — Current and past employers, roles
4. **Technical Profile** — Skills, languages, tools used
5. **Online Presence** — Platform accounts with links
6. **Digital Exposure** — Breaches, leaked data, exposed secrets
7. **Connections** — Notable professional connections

Log relevant security findings to `Ops/findings.jsonl`.
