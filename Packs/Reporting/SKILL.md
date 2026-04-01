---
name: Reporting
description: Security assessment reporting
version: 1.0.0
author: RedCyberClaw
tags: [reporting, pentest, bug-bounty, executive-summary]
---

# Reporting

Generate professional security assessment reports from raw findings, tool output, and engagement notes.

## Capabilities

- **Pentest Reports** — Full penetration testing reports with CVSS-scored findings, evidence, remediation guidance, and risk matrices. Suitable for client delivery.
- **Bug Bounty Submissions** — Platform-optimized reports for HackerOne, Bugcrowd, and similar programs. Structured for fast triage and maximum impact scoring.
- **Executive Summaries** — Non-technical overviews for leadership. Risk posture, business impact, and prioritized remediation timelines.

## Output Formats

| Format   | Use Case                          |
|----------|-----------------------------------|
| Markdown | Default. Clean, portable, diffable |
| HTML     | Client-facing with styled layout  |

## Workflows

| Workflow | Description |
|----------|-------------|
| [PentestReport](Workflows/PentestReport.md) | Complete penetration test report template |
| [BugBountyReport](Workflows/BugBountyReport.md) | Bug bounty submission optimized for triage |
| [ExecutiveSummary](Workflows/ExecutiveSummary.md) | Leadership-ready risk summary |

## Usage

Provide raw findings (tool output, screenshots, notes) and engagement metadata (scope, dates, tester). The workflow will structure everything into a professional deliverable.

### Input Variables

- `{{CLIENT}}` — Client or program name
- `{{ENGAGEMENT_DATE}}` — Assessment date range
- `{{TESTER}}` — Assessor name/handle
- `{{SCOPE}}` — In-scope targets
- `{{FINDINGS}}` — Raw finding data (tool output, notes, evidence)
- `{{CLASSIFICATION}}` — Document classification level (default: Confidential)
