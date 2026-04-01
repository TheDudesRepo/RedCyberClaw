# Bug Bounty Hunting Workflow

Systematic approach to bug bounty target assessment, optimized for finding high-impact vulnerabilities efficiently.

## Phase 1: Target Selection and Scoping

### 1.1 Read the Program Policy

Before any testing:
- Scope boundaries (which domains/apps are in scope)
- Out of scope items and exclusions
- Vulnerability types they care about
- Safe harbor and legal protections
- Payout structure and severity definitions
- Response SLA and disclosure policy

### 1.2 Update Ops/scope.json

Populate with bug bounty program scope details.

## Phase 2: Attack Surface Discovery

### 2.1 Subdomain Enumeration

```bash
# Cast a wide net
subfinder -d $DOMAIN -all -recursive -o subs.txt
amass enum -passive -d $DOMAIN >> subs.txt
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' >> subs.txt
sort -u subs.txt -o subs.txt

# Probe for live HTTP services
cat subs.txt | httpx -status-code -title -tech-detect -content-length -follow-redirects -o live.txt
```

### 2.2 Identify High-Value Targets

Prioritize:
- **Admin panels** — /admin, /dashboard, /manage, /portal
- **API endpoints** — /api/, /graphql, /v1/, /v2/
- **Authentication flows** — /login, /register, /forgot-password, /oauth
- **File upload** — /upload, /import, /attach
- **User-generated content** — /profile, /comments, /messages
- **Payment/billing** — /checkout, /billing, /subscribe
- **Staging/development** — dev.*, staging.*, test.*, beta.*

### 2.3 Technology Fingerprinting

```bash
# Identify stack for targeted testing
whatweb -i live_urls.txt --log-json=tech.json
nuclei -l live_urls.txt -t technologies/ -o tech_detected.txt
```

## Phase 3: Vulnerability Hunting

### 3.1 Low-Hanging Fruit (Quick Wins)

```bash
# Nuclei scan for known CVEs and misconfigs
nuclei -l live_urls.txt -as -severity critical,high -o nuclei_crits.txt

# Check for exposed sensitive files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/quickhits.txt -mc 200

# Subdomain takeover check
# Look for dangling CNAMEs to cloud services
cat subs.txt | dnsx -cname -resp | grep -iE "amazonaws|azurewebsites|herokuapp|github\.io|shopify|fastly"

# Check for open redirects
# Test: https://target.com/redirect?url=https://evil.com
```

### 3.2 Injection Testing

```bash
# SQL injection
sqlmap -u "https://target.com/api/search?q=test" --batch --risk 2 --level 3 --random-agent

# XSS
echo "https://target.com/search?q=FUZZ" | dalfox pipe --skip-bav

# Server-Side Template Injection
# Test payloads: {{7*7}}, ${7*7}, <%= 7*7 %>, #{7*7}
# In every input field and URL parameter

# SSRF
# Test internal URLs: http://169.254.169.254/latest/meta-data/
# In any URL parameter, webhook URL, avatar URL, import URL
```

### 3.3 Access Control Testing

```
IDOR Checklist:
- Change numeric IDs in URLs: /api/users/123 → /api/users/124
- Change UUIDs: swap your UUID for another user's
- Test horizontal access: access other users' resources
- Test vertical access: access admin functions as regular user
- Check API responses for data leakage (other users' data in responses)
- Test batch endpoints: /api/users/bulk?ids=123,124,125
```

### 3.4 Business Logic

```
Test for:
- Race conditions (concurrent requests to same endpoint)
- Price manipulation (modify price in request)
- Feature abuse (unlimited resource creation)
- Workflow bypass (skip required steps)
- Coupon/promo abuse (reuse, negative values)
- Role confusion (access features of other user types)
```

### 3.5 Authentication Bypass

```
Test for:
- Default credentials on admin panels
- Password reset token predictability
- Account enumeration via login/register/reset responses
- JWT vulnerabilities (none algorithm, weak secret, kid injection)
- OAuth misconfigurations (redirect_uri manipulation, state parameter missing)
- 2FA bypass (brute force, response manipulation, backup codes)
```

## Phase 4: Reporting

### 4.1 Write Quality Reports

For each finding, include:
1. **Title** — Clear, specific vulnerability description
2. **Severity** — CVSS score with justification
3. **Steps to Reproduce** — Numbered steps anyone can follow
4. **Impact** — What an attacker can achieve
5. **Proof of Concept** — Screenshots, HTTP requests/responses, video
6. **Remediation** — Specific fix recommendations

### 4.2 Report Template

Use [BugBountyReport](../Reporting/Workflows/BugBountyReport.md) workflow for structured reports.

## Tips for Success

1. **Go deep, not wide** — Thorough testing of one application beats shallow scans of many
2. **Read the source** — JavaScript files often reveal hidden endpoints and logic
3. **Test business logic** — Automated scanners miss logic bugs; they're high-value
4. **Check mobile APIs** — Often less secured than web endpoints
5. **Look at older subdomains** — Staging and legacy systems have weaker security
6. **Chain vulnerabilities** — Low-severity bugs chained together = critical impact
7. **Document everything** — You'll thank yourself when writing the report
