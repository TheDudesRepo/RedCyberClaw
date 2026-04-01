# Red Team Critique

Apply adversarial thinking from multiple attacker perspectives to stress-test plans, architectures, and defenses.

---

## The 12 Attacker Personas

Evaluate the target through each lens:

| # | Persona | Motivation | Capabilities |
|---|---------|-----------|-------------|
| 1 | **Script Kiddie** | Clout, chaos | Public tools, known exploits, default creds |
| 2 | **Bug Bounty Hunter** | Money, reputation | Web skills, recon automation, creative chaining |
| 3 | **Disgruntled Insider** | Revenge, profit | Internal access, knows systems, has credentials |
| 4 | **Corporate Spy** | Competitive intel | Funded, patient, social engineering |
| 5 | **Ransomware Operator** | Money | Automated toolkits, RaaS, data exfil |
| 6 | **APT (Nation-State)** | Strategic advantage | Zero-days, custom malware, unlimited time |
| 7 | **Supply Chain Attacker** | Wide impact | Code injection, dependency confusion, build poisoning |
| 8 | **Social Engineer** | Access | Phishing, pretexting, physical intrusion |
| 9 | **Physical Intruder** | Device access | Tailgating, USB drops, badge cloning |
| 10 | **Cloud Attacker** | Data, compute | IAM exploitation, metadata abuse, lateral cloud movement |
| 11 | **AI/ML Attacker** | Model manipulation | Prompt injection, training data poisoning, model extraction |
| 12 | **Regulatory Auditor** | Compliance gaps | Checklist-based, documentation-focused, policy review |

---

## How to Use

### Critiquing an Attack Plan
For each persona, ask:
1. Would this attack work against a defender using persona X's mindset?
2. What would persona X do differently?
3. What detection would persona X trigger?
4. What's the escape plan if caught?

### Critiquing a Defense
For each persona, ask:
1. How would persona X bypass this control?
2. What's the weakest link from persona X's perspective?
3. What blind spots does this defense have against persona X?
4. What would persona X attack instead?

### Critiquing an Architecture
For each persona, ask:
1. Where's the entry point for persona X?
2. What's the highest-value target persona X would go for?
3. What lateral movement path exists for persona X?
4. Can persona X achieve persistence undetected?

---

## Output Format

```markdown
## Red Team Critique: [Target]

### Weaknesses Identified
1. [Weakness] — exploitable by [personas]
2. [Weakness] — exploitable by [personas]

### Blind Spots
- [What was overlooked]

### Alternative Attack Paths
- [Path not considered]

### Recommendations
1. [Mitigation for weakness 1]
2. [Mitigation for weakness 2]

### Risk Rating
- Likelihood: [High/Medium/Low]
- Impact: [Critical/High/Medium/Low]
- Overall: [Critical/High/Medium/Low]
```
