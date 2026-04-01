---
name: PromptInjection
description: AI/LLM security testing — prompt injection, jailbreaks, and defense evaluation
version: 1.0.0
author: RedCyberClaw
tags: [ai-security, llm, prompt-injection, red-team, jailbreak]
---

# PromptInjection

Offensive testing pack for AI and LLM-powered applications. Covers the full attack lifecycle: reconnaissance, direct injection, indirect injection via data channels, multi-stage attack chains, and defense evaluation.

## Capabilities

| Capability | Description |
|---|---|
| **System Prompt Extraction** | Techniques to leak the hidden system prompt from target applications |
| **Jailbreak Testing** | Bypass safety filters, content policies, and alignment guardrails |
| **Indirect Injection** | Inject payloads through RAG documents, tool outputs, web scrapes, images, and API responses |
| **Multi-Stage Attacks** | Multi-turn conversation chains that progressively escalate trust and override boundaries |
| **Defense Evaluation** | Assess effectiveness of input/output filters, guardrails, and monitoring |

## Tool Preferences

**Manual first, automate second.** Hand-crafted payloads teach you the target's behavior. Scanners find breadth after you find depth.

### Primary — Manual Crafting
- Direct interaction with the target application
- Custom payload development based on observed behavior
- Iterative refinement based on responses

### Secondary — Automated Scanners
| Tool | Use Case |
|---|---|
| `garak` | Broad vulnerability scanning across known attack categories |
| `promptmap` | Automated prompt injection testing with payload libraries |
| `rebuff` | Test prompt injection detection systems |
| `pyrit` | Microsoft's red teaming orchestrator for generative AI |

### Supporting Tools
- `burpsuite` / `mitmproxy` — Intercept and modify API calls to LLM backends
- `curl` / `httpie` — Direct API interaction, bypassing frontend filters
- `jq` — Parse and manipulate JSON payloads and responses
- `base64` / `xxd` — Encode payloads to bypass input sanitization

## Workflows

Execute in order for full assessments, or pick individual workflows for targeted testing.

| # | Workflow | Purpose |
|---|---|---|
| 1 | [AppRecon](Workflows/AppRecon.md) | Fingerprint the target — model, tools, data sources, filters |
| 2 | [DirectInjection](Workflows/DirectInjection.md) | Attack input surfaces directly with injection payloads |
| 3 | [IndirectInjection](Workflows/IndirectInjection.md) | Inject through data channels the app consumes |
| 4 | [MultiStageAttack](Workflows/MultiStageAttack.md) | Chain multi-turn attacks for complex exploitation |

## Rules of Engagement

1. **Scope first.** Only test applications you have authorization to test.
2. **Document everything.** Every payload, every response, every observation.
3. **Minimize collateral.** Extraction > destruction. Read > write. Observe > modify.
4. **Report responsibly.** Findings go to the application owner, not Twitter.

## Output

For each finding, document:
- **Vulnerability class** (direct injection, indirect injection, jailbreak, data exfil)
- **Attack vector** (input field, document upload, API parameter, etc.)
- **Payload** (exact text that triggered the behavior)
- **Impact** (what an attacker gains — data leak, policy bypass, tool abuse)
- **Reproducibility** (deterministic, probabilistic, model-dependent)
- **Recommended fix** (input validation, output filtering, architecture change)
