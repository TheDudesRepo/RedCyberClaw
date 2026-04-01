# Deep Research Workflow

Multi-source parallel research for security topics — CVEs, threat intel, vendor analysis, technique research.

---

## Methodology

### 1. Define the Question
Be specific. Bad: "How does XSS work?" Good: "What DOM-based XSS vectors bypass DOMPurify 3.x?"

### 2. Parallel Source Collection

```bash
# Web search — multiple angles
# Search 1: Technical details
web_search "CVE-YYYY-XXXXX proof of concept exploit"
# Search 2: Vendor advisory
web_search "CVE-YYYY-XXXXX advisory patch"
# Search 3: Community analysis
web_search "CVE-YYYY-XXXXX analysis blog writeup"
# Search 4: Exploit availability
web_search "CVE-YYYY-XXXXX github exploit poc"
```

### 3. Source Evaluation
Rate each source:
- **Authority** — vendor advisory > security researcher > random blog
- **Recency** — newer is better for CVEs and techniques
- **Technical depth** — code > description > summary
- **Corroboration** — does it match other sources?

### 4. Cross-Reference
- Compare technical details across sources
- Identify contradictions
- Note gaps — what's NOT being said

### 5. Synthesize
Produce a structured summary:
- **TL;DR** — one paragraph
- **Technical details** — root cause, affected versions, attack vector
- **Exploitation** — known PoCs, conditions, difficulty
- **Mitigation** — patches, workarounds, detection
- **References** — all sources with URLs

---

## Research Templates

### CVE Research
1. NVD entry → CVSS, affected products, references
2. Vendor advisory → patch details, workarounds
3. Exploit-DB / GitHub → existing PoCs
4. Blog writeups → detailed analysis, attack scenarios
5. Patch diff → exact code change

### Threat Actor Research
1. MITRE ATT&CK → TTPs, associated groups
2. Vendor threat reports → campaigns, IOCs
3. Academic papers → novel techniques
4. Dark web monitoring → tools, infrastructure

### Tool/Technique Research
1. Official documentation
2. GitHub → source code, issues, recent commits
3. Security conference talks (DEF CON, Black Hat)
4. Community writeups and tutorials
5. Comparison with alternatives

---

## Output Format

```markdown
# Research: [Topic]

## Summary
[1-2 paragraph overview]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Technical Details
[In-depth analysis]

## Implications
[What this means for the engagement/research]

## Sources
1. [Title](URL) — accessed YYYY-MM-DD
2. [Title](URL) — accessed YYYY-MM-DD
```
