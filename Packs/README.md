# Packs — RedCyberClaw Methodology Packs

Packs are structured collections of skills and workflows that guide the AI assistant through offensive security operations.

## Kill Chain Flow

```
                            ┌─────────────────┐
                            │   Scope Guard    │
                            │  Ops/scope.json  │
                            └────────┬────────┘
                                     │
                                     ▼
              ┌──────────────────────────────────────────┐
              │              RECONNAISSANCE               │
              │  Packs/Recon/ + Packs/OSINT/             │
              │  Subdomains, DNS, Ports, OSINT           │
              │  🟢 Full Auto                             │
              └──────────────────────┬───────────────────┘
                                     │
                                     ▼
              ┌──────────────────────────────────────────┐
              │            WEB ASSESSMENT                 │
              │  Packs/WebAssessment/                    │
              │  OWASP Top 10, Fuzzing, Logic Bugs      │
              │  🟢 Full Auto                             │
              └──────────────────────┬───────────────────┘
                                     │
                          ┌──────────┴──────────┐
                          ▼                     ▼
              ┌────────────────────┐  ┌────────────────────┐
              │  PROMPT INJECTION  │  │   EXPLOITATION     │
              │  Packs/Prompt      │  │  Packs/Exploit     │
              │  Injection/        │  │  ation/            │
              │  🟢 Auto (AI apps) │  │  🟡 Confirm Only    │
              └────────┬───────────┘  └────────┬───────────┘
                       │                       │
                       └───────────┬───────────┘
                                   ▼
              ┌──────────────────────────────────────────┐
              │          POST-EXPLOITATION                │
              │  Packs/PostExploit/                      │
              │  PrivEsc, Lateral Move, Persistence      │
              │  🟡 Confirm Only                          │
              └──────────────────────┬───────────────────┘
                                     │
                                     ▼
              ┌──────────────────────────────────────────┐
              │             REPORTING                     │
              │  Packs/Reporting/                        │
              │  Pentest Report, Bug Bounty, Exec Brief  │
              │  🟢 Full Auto                             │
              └──────────────────────────────────────────┘

        ┌──────────────────────────────────────────────────┐
        │  SUPPORT PACKS (available at any phase)          │
        │  Packs/Research/  — Multi-agent deep research    │
        │  Packs/Thinking/  — Red team critique, analysis  │
        └──────────────────────────────────────────────────┘
```

## Pack Index

| Pack | Description | Workflows |
|------|-------------|-----------|
| **[Recon](Recon/)** | Attack surface discovery | DomainRecon, NetworkRecon, PassiveRecon |
| **[OSINT](OSINT/)** | Intelligence gathering | PeopleLookup, CompanyIntel |
| **[WebAssessment](WebAssessment/)** | Web application testing | MasterMethodology, FuzzingGuide, BugBountyHunting, ThreatModel |
| **[PromptInjection](PromptInjection/)** | AI/LLM security | DirectInjection, IndirectInjection, MultiStageAttack, AppRecon |
| **[Exploitation](Exploitation/)** | Exploit development | ExploitDev, Payloads, CVERepro, ExploitChain |
| **[PostExploit](PostExploit/)** | Post-compromise | PrivEsc, LateralMovement, Persistence |
| **[Reporting](Reporting/)** | Report generation | PentestReport, BugBountyReport, ExecutiveSummary |
| **[Research](Research/)** | Deep research | DeepResearch |
| **[Thinking](Thinking/)** | Adversarial analysis | RedTeamCritique, FirstPrinciples |

## How Packs Work

Each pack contains:

1. **SKILL.md** — The skill definition with capabilities, tools, and routing logic
2. **Workflows/** — Step-by-step methodology files for specific tasks
3. **Data/** — Reference data, wordlists, templates (optional)

The AI assistant reads the SKILL.md to understand capabilities, then follows the appropriate workflow for the requested task.
