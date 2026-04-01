# 🩸 RedCyberClaw

> **AI-powered offensive security platform for red teamers, bug bounty hunters, and security researchers.**

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-CLI-black.svg)]()
[![AI Engine](https://img.shields.io/badge/Engine-Claude%20Code%20%7C%20Codex-purple.svg)]()
[![Phase](https://img.shields.io/badge/Phase-Active%20Development-orange.svg)]()

RedCyberClaw turns AI coding assistants into offensive security operators. It provides structured methodology packs, engagement management, and automated workflows that leverage Claude Code, Codex, and other AI assistants as execution engines for penetration testing, vulnerability research, and bug bounty hunting.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    RedCyberClaw                         │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ CLAUDE.md│  │ Ops/     │  │ .claude/         │  │
│  │ Project  │  │ Scope &  │  │ settings.json    │  │
│  │ Config   │  │ Engage   │  │ 130+ tools       │  │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│       │              │                  │            │
│       ▼              ▼                  ▼            │
│  ┌──────────────────────────────────────────────┐   │
│  │           AI Execution Engine                 │   │
│  │    (Claude Code / Codex / OpenCode / Pi)      │   │
│  └──────────────────────┬───────────────────────┘   │
│                         │                            │
│       ┌─────────────────┼─────────────────┐         │
│       ▼                 ▼                 ▼         │
│  ┌─────────┐   ┌──────────────┐   ┌───────────┐   │
│  │  Packs/ │   │  Reference/  │   │   Tools   │   │
│  │ Skills &│   │  Source code  │   │  nmap,    │   │
│  │Workflows│   │  analysis    │   │  nuclei,  │   │
│  └─────────┘   └──────────────┘   │  ffuf...  │   │
│                                    └───────────┘   │
└─────────────────────────────────────────────────────┘
```

## Kill Chain

RedCyberClaw organizes offensive operations into a structured kill chain with AI automation levels:

```
 ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
 │  Recon   │───▶│  OSINT   │───▶│   Web    │───▶│ Exploit  │───▶│  Post-   │───▶│ Report   │
 │          │    │          │    │  Assess  │    │          │    │ Exploit  │    │          │
 │ 🟢 AUTO  │    │ 🟢 AUTO  │    │ 🟢 AUTO  │    │ 🟡 CONFIRM│   │ 🟡 CONFIRM│   │ 🟢 AUTO  │
 └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

| Phase | Automation | Description |
|-------|-----------|-------------|
| 🟢 Recon | Full Auto | Subdomain enum, DNS, port scanning, service fingerprinting |
| 🟢 OSINT | Full Auto | People, company, and entity intelligence gathering |
| 🟢 Web Assessment | Full Auto | OWASP testing, fuzzing, vulnerability scanning |
| 🟡 Exploitation | Confirm Only | Exploit development, payload generation, CVE reproduction |
| 🟡 Post-Exploit | Confirm Only | Privilege escalation, lateral movement, persistence |
| 🟢 Reporting | Full Auto | Pentest reports, bug bounty submissions, executive summaries |

## Pack Index

| Pack | Purpose | Key Tools |
|------|---------|-----------|
| [Recon](Packs/Recon/) | Attack surface mapping | nmap, amass, subfinder, httpx, masscan |
| [OSINT](Packs/OSINT/) | Intelligence gathering | sherlock, holehe, theharvester, recon-ng |
| [WebAssessment](Packs/WebAssessment/) | Web app pentesting | ffuf, nuclei, sqlmap, dalfox, nikto |
| [PromptInjection](Packs/PromptInjection/) | AI/LLM security testing | Custom payloads, multi-stage attacks |
| [Exploitation](Packs/Exploitation/) | Exploit development | msfconsole, searchsploit, custom PoCs |
| [PostExploit](Packs/PostExploit/) | Post-compromise ops | linpeas, bloodhound, impacket, chisel |
| [Reporting](Packs/Reporting/) | Report generation | Markdown templates, CVSS scoring |
| [Research](Packs/Research/) | Multi-agent research | Parallel web research, deep analysis |
| [Thinking](Packs/Thinking/) | Adversarial analysis | Red team critique, first principles |

## Quick Start

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude login
```

### 2. Install RedCyberClaw

```bash
git clone https://github.com/TheDudesRepo/RedCyberClaw.git
cd RedCyberClaw
chmod +x install.sh && ./install.sh
```

### 3. Set your target scope

```bash
nano Ops/scope.json
```

### 4. Launch

```bash
./rcc
```

That's it. The `rcc` launcher handles everything — branding, environment setup, telemetry killing, and launching the AI engine.

Optionally install `rcc` globally so you can run it from anywhere:
```bash
sudo ln -sf $(pwd)/rcc /usr/local/bin/rcc
```

### 5. Start hacking

Tell the AI:
```
"Run recon against example.com"
"Fuzz https://target.com for hidden endpoints"
"Generate a pentest report from findings"
```

### 🧠 Persistent Memory

RedCyberClaw maintains engagement state so the AI never loses context across sessions:

| File | Purpose |
|------|---------|
| `Ops/engagement.md` | Rolling narrative log — actions taken, tools run, paths explored |
| `Ops/findings.jsonl` | Structured vulnerability database (auto-appended) |
| `Ops/scope.json` | Target definition and rules of engagement |

Claude reads these files on startup and updates them as it works. Pick up where you left off, every time.

## Directory Structure

```
RedCyberClaw/
├── CLAUDE.md                 # AI assistant project instructions
├── .claude/settings.json     # Pre-approved security tools (130+)
├── .env.example              # API key template
├── Ops/                      # Engagement management
│   ├── scope.json            # Target scope definition
│   ├── engagement.md         # Session log
│   └── findings.jsonl        # Structured findings (auto-generated)
├── Packs/                    # Methodology packs (skills + workflows)
│   ├── Recon/
│   ├── OSINT/
│   ├── WebAssessment/
│   ├── PromptInjection/
│   ├── Exploitation/
│   ├── PostExploit/
│   ├── Reporting/
│   ├── Research/
│   └── Thinking/
└── Reference/                # Claude Code internals analysis
    └── claude-code-source/   # Relevant source files
```

## Uninstall / Clean Reinstall

To completely remove RedCyberClaw from your system:

```bash
# Back up your engagement data first (optional)
cp -r Ops/ ~/rcc-backup/

# Run the uninstaller
./uninstall.sh
```

This removes the RedCyberClaw directory, the global `rcc` symlink, and nothing else. Claude Code stays installed.

**For a clean reinstall**, just uninstall and re-clone:
```bash
./uninstall.sh
git clone https://github.com/TheDudesRepo/RedCyberClaw.git
cd RedCyberClaw
./install.sh
```

To also remove Claude Code entirely:
```bash
npm uninstall -g @anthropic-ai/claude-code
```

## Requirements

- An AI coding assistant (Claude Code, Codex, OpenCode, etc.)
- Standard offensive security tooling (Kali Linux recommended)
- API keys for enrichment services (Shodan, Censys, etc.)

## Legal Disclaimer

⚠️ **RedCyberClaw is intended for authorized security testing only.**

Use of this platform against systems without explicit written authorization is illegal and unethical. The authors assume no liability for misuse. Always:

- Obtain written authorization before testing
- Define scope clearly in `Ops/scope.json`
- Follow rules of engagement
- Report findings responsibly

**You are solely responsible for your actions.**

---

*Architecture inspired by open-source AI infrastructure patterns.*

MIT License • Copyright 2026 TheDude
