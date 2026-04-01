# Executive Summary Workflow

Generate a non-technical security summary for leadership and board-level stakeholders.

## Purpose

Translate technical assessment findings into business language. No jargon, no CVE numbers, no exploit details — just risk, impact, and what needs to happen next.

---

## Template

# Security Assessment — Executive Summary

**Prepared for:** {{CLIENT}} — {{AUDIENCE}} (CISO / Board / Executive Team)
**Assessment Period:** {{START_DATE}} — {{END_DATE}}
**Report Date:** {{REPORT_DATE}}
**Classification:** {{CLASSIFICATION}}

---

## Overall Security Posture

**Rating: `[CRITICAL | NEEDS IMPROVEMENT | ACCEPTABLE | STRONG]`**

Provide a 2–3 sentence assessment of the organization's current security posture. Use plain language:

> The assessment identified several significant vulnerabilities that, if exploited, could result in unauthorized access to customer data and disruption of core business services. While foundational security controls are in place, critical gaps in [area] and [area] require immediate attention. The organization's risk exposure is elevated compared to industry benchmarks.

### Posture Definitions

| Rating | Meaning |
|--------|---------|
| **Critical** | Active exploitation likely. Immediate executive action required. Business continuity at risk. |
| **Needs Improvement** | Significant gaps exist. Exploitation is plausible. Remediation should begin within 1–2 weeks. |
| **Acceptable** | Minor issues found. Security controls are generally effective. Standard remediation timelines apply. |
| **Strong** | No significant findings. Controls exceed baseline requirements. Continue current security program. |

---

## Key Findings Overview

Summarize the top 3–5 findings in business terms. No technical details — focus on what's at risk.

| # | Finding | Business Risk | Priority |
|---|---------|---------------|----------|
| 1 | {{FINDING_SUMMARY}} | {{BUSINESS_RISK}} | Immediate |
| 2 | | | This Week |
| 3 | | | This Month |
| 4 | | | This Quarter |
| 5 | | | Next Quarter |

### Finding Breakdown by Severity

| Severity | Count | Meaning |
|----------|-------|---------|
| Critical | {{N}} | Could cause major breach or outage if exploited |
| High | {{N}} | Significant risk requiring prompt attention |
| Medium | {{N}} | Moderate risk, standard remediation timeline |
| Low | {{N}} | Minor issues, address during regular maintenance |

---

## Business Impact Assessment

For each critical/high finding, describe the business impact without technical terminology:

### 1. {{FINDING_NAME}}

**What could happen:** Describe the worst realistic business outcome (data breach, financial loss, regulatory penalty, reputational damage, operational disruption).

**Who is affected:** Customers, employees, partners, specific business units.

**Estimated exposure:** Quantify where possible — number of records, estimated financial impact, regulatory implications (GDPR, PCI-DSS, HIPAA, SOX).

**Likelihood:** How probable is exploitation given current threat landscape and attacker motivation.

---

## Remediation Priority

### Immediate (0–48 hours)

Actions that must happen now to reduce critical risk:

- {{ACTION_1}}
- {{ACTION_2}}

### Short-Term (1–2 weeks)

High-priority fixes that require planning but cannot wait:

- {{ACTION_3}}
- {{ACTION_4}}

### Medium-Term (30–60 days)

Process improvements and architectural changes:

- {{ACTION_5}}
- {{ACTION_6}}

### Long-Term (60–90 days)

Strategic security program enhancements:

- {{ACTION_7}}
- {{ACTION_8}}

---

## Estimated Remediation Investment

| Phase | Effort Estimate | Resource Needs | Cost Range |
|-------|----------------|----------------|------------|
| Immediate | {{HOURS}} hours | {{TEAM}} | ${{COST}} |
| Short-Term | {{HOURS}} hours | {{TEAM}} | ${{COST}} |
| Medium-Term | {{HOURS}} hours | {{TEAM}} | ${{COST}} |
| Long-Term | {{HOURS}} hours | {{TEAM}} | ${{COST}} |

---

## Remediation Timeline

```
Week 1    ████████████ Critical fixes deployed
Week 2    ████████     High-priority patches applied
Week 3-4  ██████       Process changes implemented
Month 2   ████         Architecture improvements begin
Month 3   ██           Strategic program enhancements
```

---

## Comparison to Industry

| Metric | {{CLIENT}} | Industry Average | Assessment |
|--------|-----------|-----------------|------------|
| Critical findings | {{N}} | {{N}} | Above/Below Average |
| Time to patch (critical) | {{DAYS}} days | 15 days | — |
| MFA adoption | {{PCT}}% | 87% | — |
| Security training completion | {{PCT}}% | 72% | — |

---

## Recommended Next Steps

1. **Executive sponsor** — Assign a senior leader to own the remediation program
2. **Remediation kickoff** — Schedule a technical planning session within 48 hours
3. **Retest engagement** — Schedule a validation assessment in {{TIMEFRAME}} to verify fixes
4. **Ongoing program** — Consider quarterly assessments and continuous monitoring

---

## Appendix: Assessment Scope Summary

- **Targets tested:** {{TARGET_COUNT}} systems/applications
- **Testing type:** {{TYPE}} (External / Internal / Web Application / Network / Red Team)
- **Methodology:** Industry-standard penetration testing aligned with {{FRAMEWORK}}
- **Limitations:** Any access restrictions, time constraints, or excluded targets

---

**Questions?** Contact {{TESTER_CONTACT}} for clarification on any findings or recommendations.

---

## Writing Guidelines

When populating this template:

- **No technical jargon** — Replace "SQL injection" with "a flaw that could allow attackers to access the customer database"
- **Quantify impact** — "500,000 customer records" not "significant data exposure"
- **Use business language** — Revenue, customers, compliance, reputation, operations
- **Be direct** — State the risk clearly. Don't hedge with "could potentially maybe"
- **Include cost of inaction** — What happens if nothing is done (regulatory fines, breach costs, insurance implications)
- **Keep it under 3 pages** — Executives won't read more
