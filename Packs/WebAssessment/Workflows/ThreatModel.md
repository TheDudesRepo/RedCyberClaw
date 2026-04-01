# STRIDE Threat Modeling Workflow

Systematic threat identification using the STRIDE framework for web applications and systems.

## Overview

STRIDE categorizes threats into six types:

| Category | Threat | Property Violated |
|----------|--------|-------------------|
| **S**poofing | Impersonating a user or system | Authentication |
| **T**ampering | Modifying data or code | Integrity |
| **R**epudiation | Denying performed actions | Non-repudiation |
| **I**nformation Disclosure | Exposing data to unauthorized parties | Confidentiality |
| **D**enial of Service | Making system unavailable | Availability |
| **E**levation of Privilege | Gaining unauthorized access levels | Authorization |

## Phase 1: System Decomposition

### 1.1 Identify Components

Map the application architecture:

```
- Web frontend (SPA, SSR, static)
- API gateway / load balancer
- Backend services (microservices, monolith)
- Databases (SQL, NoSQL, cache)
- Authentication provider (IdP, OAuth, SAML)
- File storage (S3, local filesystem)
- Message queues (RabbitMQ, Kafka, SQS)
- Third-party integrations (payment, email, SMS)
- CDN / WAF
- Admin interfaces
```

### 1.2 Data Flow Diagram

Create a DFD showing:
- External entities (users, admins, third parties)
- Processes (web server, API, workers)
- Data stores (databases, caches, file systems)
- Data flows (HTTP, gRPC, database queries, file I/O)
- Trust boundaries (internet/DMZ, DMZ/internal, service/database)

### 1.3 Identify Trust Boundaries

Mark where trust level changes:
- Internet → WAF/CDN
- CDN → Web server
- Web server → API server
- API server → Database
- User → Admin
- Internal service → External API

## Phase 2: Threat Identification

### 2.1 Apply STRIDE to Each Component

For each component and data flow, ask:

**Spoofing:**
- Can an attacker impersonate a legitimate user?
- Can a service be spoofed (DNS hijack, ARP spoof)?
- Are authentication tokens predictable or stealable?
- Is mutual TLS enforced between services?

**Tampering:**
- Can request data be modified in transit?
- Can database records be altered without authorization?
- Can client-side validation be bypassed?
- Are integrity checks (HMAC, signatures) in place?

**Repudiation:**
- Are all sensitive actions logged?
- Can logs be tampered with?
- Are timestamps and user IDs recorded?
- Is there audit trail for financial transactions?

**Information Disclosure:**
- What data is exposed in API responses?
- Are error messages revealing internal details?
- Is sensitive data encrypted at rest and in transit?
- Are debug endpoints accessible in production?
- Is PII properly handled and minimized?

**Denial of Service:**
- Are there rate limits on API endpoints?
- Can an attacker exhaust server resources?
- Is there protection against algorithmic complexity attacks?
- Are file upload sizes limited?
- Is there DDoS protection?

**Elevation of Privilege:**
- Can a regular user access admin functions?
- Are authorization checks performed on every request?
- Can mass assignment change user roles?
- Are there privilege escalation paths through chained bugs?

## Phase 3: Risk Assessment

### 3.1 Rate Each Threat

Use DREAD or simple High/Medium/Low:

| Factor | Description |
|--------|-------------|
| **Likelihood** | How likely is this to be exploited? |
| **Impact** | What's the damage if exploited? |
| **Effort** | How much skill/effort to exploit? |
| **Detectability** | How easy is it to detect the attack? |

### 3.2 Prioritize

```
Critical: High likelihood + High impact
High: Medium likelihood + High impact, or High likelihood + Medium impact
Medium: Medium likelihood + Medium impact
Low: Low likelihood + Low impact
```

## Phase 4: Mitigation Mapping

For each identified threat, document:

1. **Threat description** — What could happen
2. **Attack vector** — How it would be exploited
3. **Current controls** — Existing mitigations
4. **Gaps** — Missing or insufficient controls
5. **Recommended mitigations** — Specific technical controls
6. **Verification** — How to test the mitigation works

## Phase 5: Output

Produce a threat model document containing:

1. **System overview** and architecture diagram
2. **Data flow diagram** with trust boundaries
3. **Threat table** — all identified threats with STRIDE category
4. **Risk matrix** — prioritized by likelihood and impact
5. **Mitigation plan** — controls for each threat
6. **Testing recommendations** — specific test cases derived from threats

Log high-priority threats as findings in `Ops/findings.jsonl`.
