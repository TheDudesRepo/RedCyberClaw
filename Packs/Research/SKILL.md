---
name: Research
description: Multi-source parallel research
version: 1.0.0
author: RedCyberClaw
tags: [research, osint, threat-intel, cve, deep-research]
---

# Research

Conduct deep, multi-source research with parallel execution, source triangulation, and proper citation tracking.

## Capabilities

- **Parallel Search** — Query multiple search engines and data sources simultaneously to maximize coverage and reduce bias from any single source.
- **Source Triangulation** — Cross-reference findings across independent sources. A claim backed by three unrelated sources is stronger than one backed by ten copies of the same press release.
- **Citation Tracking** — Maintain full provenance for every claim. Track original source, retrieval date, and confidence level.
- **CVE Research** — Deep-dive vulnerability analysis using NVD, vendor advisories, exploit databases, and researcher disclosures.
- **Threat Intelligence** — Aggregate threat actor profiles, TTPs, IOCs, and campaign timelines from public and semi-public sources.
- **Vendor/Product Analysis** — Evaluate security tools, services, and vendors through documentation review, community feedback, and independent testing data.

## Workflows

| Workflow | Description |
|----------|-------------|
| [DeepResearch](Workflows/DeepResearch.md) | Full research methodology with parallel execution |

## Usage

Provide a research question or topic. The workflow will decompose it into searchable queries, execute parallel searches, evaluate sources, cross-reference findings, and produce a cited synthesis.

### Input Variables

- `{{QUESTION}}` — Primary research question
- `{{SCOPE}}` — Breadth constraints (time range, source types, geographic focus)
- `{{DEPTH}}` — shallow (quick survey), standard (balanced), deep (exhaustive)
- `{{OUTPUT_FORMAT}}` — report, briefing, raw-notes
