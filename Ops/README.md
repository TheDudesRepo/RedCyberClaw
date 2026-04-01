# Ops — Engagement Management

This directory manages the operational state of your security engagement.

## Phase Model

Every engagement progresses through phases:

```
Recon → OSINT → Web Assessment → Exploitation → Post-Exploitation → Reporting
```

The current phase is tracked in `scope.json`. The AI assistant uses this to determine what actions are permitted:

- **Phases 1-3 (Recon, OSINT, Web Assessment):** Full automation permitted
- **Phases 4-5 (Exploitation, Post-Exploitation):** Confirmation required before every action
- **Phase 6 (Reporting):** Full automation permitted

## Scope Guard

`scope.json` defines what can and cannot be tested. The AI assistant **must** check this file before running any tool against any target. If a target is not explicitly in scope, testing is denied.

### Scope Structure

- **in_scope**: Domains, IPs, CIDRs, URLs that are authorized for testing
- **out_of_scope**: Specific hosts, paths, or services explicitly excluded
- **rules_of_engagement**: Time windows, prohibited actions, notification requirements

## Findings Format

All findings are logged to `findings.jsonl` (one JSON object per line):

```json
{
  "id": "FIND-001",
  "timestamp": "2026-03-31T12:00:00Z",
  "phase": "web-assessment",
  "severity": "critical|high|medium|low|info",
  "title": "Short description",
  "target": "https://target.com/path",
  "description": "Detailed description of the vulnerability",
  "evidence": "Tool output, screenshots, or reproduction steps",
  "cvss": 9.1,
  "cwe": "CWE-XXX",
  "remediation": "How to fix it",
  "tools_used": ["tool1", "tool2"],
  "references": ["https://..."]
}
```

## Files

| File | Purpose |
|------|---------|
| `scope.json` | Target scope and rules of engagement |
| `engagement.md` | Session activity log |
| `findings.jsonl` | Structured vulnerability findings (auto-generated) |
| `exploits/` | PoC code and exploit artifacts (gitignored) |
| `loot/` | Extracted data and credentials (gitignored) |
| `screenshots/` | Evidence screenshots (gitignored) |
