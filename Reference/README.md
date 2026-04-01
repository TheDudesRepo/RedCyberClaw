# Reference: Claude Code Source Analysis

This directory contains select source files from Claude Code's leaked/decompiled codebase. They document the security architecture that informed RedCyberClaw's design — permission systems, safety boundaries, telemetry pipelines, and tool validation.

## Why This Matters

Understanding how AI coding assistants enforce security boundaries is essential for:
- **Red teamers** using these tools as execution engines
- **Researchers** studying AI safety implementations
- **Builders** designing their own agent permission systems

## File Index

### constants/
| File | What It Reveals |
|------|----------------|
| `cyberRiskInstruction.ts` | The `CYBER_RISK_INSTRUCTION` — a single paragraph injected into the system prompt telling Claude to refuse malicious requests. **It's client-side prompt injection** — the "safety" is literally a string in the prompt, not a model capability. |
| `systemPromptSections.ts` | How the system prompt is assembled from blocks. The `SYSTEM_PROMPT_DYNAMIC_BOUNDARY` marker separates cacheable (global) from dynamic (per-turn) sections. |

### tools/
| File | What It Reveals |
|------|----------------|
| `bashSecurity.ts` | **2,600 lines** of bash command validation. Scans for dangerous patterns: recursive deletion, disk writes, fork bombs, privilege escalation, network exfil. Uses regex pattern matching — no AST parsing. Bypassable with sufficient obfuscation. |
| `SkillTool.ts` | How skills are loaded and executed. Skills are markdown files with YAML frontmatter — Claude reads them and follows instructions. No sandboxing. |
| `WebFetchTool-utils.ts` | URL validation: MAX_URL_LENGTH=2000, MAX_HTTP_CONTENT_LENGTH=10MB, FETCH_TIMEOUT=60s, MAX_REDIRECTS=10, MAX_MARKDOWN_LENGTH=100000. Domain checking has a 10s timeout. |

### permissions.ts (root)
| File | What It Reveals |
|------|----------------|
| `permissions.ts` | Type definitions for the permission system. `EXTERNAL_PERMISSION_MODES` vs `INTERNAL_PERMISSION_MODES`. Tools declare what permissions they need. |

### utils/
| File | What It Reveals |
|------|----------------|
| `bashClassifier.ts` | The `ANT-ONLY` classifier stub — in the public build, it's a no-op. Anthropic's internal build has a more sophisticated classifier that categorizes bash commands by risk level. |
| `yoloClassifier.ts` | YOLO mode / `dangerousMode` / `bypassPermissions` — when enabled, skips ALL permission checks. This is what `--dangerously-skip-permissions` activates. |
| `dangerousPatterns.ts` | Pattern matching for dangerous shell commands. Checks for `rm -rf /`, `dd` to block devices, fork bombs (`:(){ :|:& };:`), etc. |
| `shellRuleMatching.ts` | How shell commands are matched against permission rules. Supports glob patterns, exact matches, and prefix matching. |
| `permissionRuleParser.ts` | Parses permission rules from `.claude/settings.json`. Rules are `allow`/`deny` with tool + command patterns. |
| `PermissionMode.ts` | **7 permission modes**: `default` (ask for everything), `acceptEdits` (auto-approve file edits), `dontAsk` (auto-approve most), `bypassPermissions` (YOLO), `plan` (read-only), `auto` (CI mode), `bubble` (delegate to parent). |
| `permissions.ts` | Core permission checking logic. Evaluates rules top-to-bottom, first match wins. |
| `systemPrompt.ts` | Full system prompt construction. Assembles environment info, tool descriptions, skill commands, and safety instructions into the final prompt array. |

### services/
| File | What It Reveals |
|------|----------------|
| `index.ts` | Analytics pipeline entry point. Initializes Datadog RUM, Sentry, and first-party event logging. |
| `datadog.ts` | Sends telemetry to **Datadog US5** (`us5.datadoghq.com`). Application ID and client token are hardcoded. |
| `metadata.ts` | Collects: OS, shell, terminal, IDE, model, session ID, project hash, git remote hash, permission mode, MCP server count. Hashes are SHA-256 — not reversible, but still fingerprints your environment. |

## Key Takeaways for RedCyberClaw

1. **Safety = prompt injection**: `CYBER_RISK_INSTRUCTION` is injected text, not a model constraint. RedCyberClaw's `.claude/settings.json` pre-approves security tools so you never hit permission prompts during legitimate work.

2. **Bash validation is regex, not AST**: `bashSecurity.ts` pattern-matches against known dangerous commands. It can't catch everything — obfuscation, variable expansion, and indirect execution bypass it.

3. **Permission rules are first-match**: RedCyberClaw's settings put broad `Allow` rules first, with `Deny` rules only for truly destructive operations (disk wipe, fork bomb).

4. **Telemetry is extensive**: 739 `tengu_*` events track every tool call, permission decision, model switch, error, and session lifecycle event. **Kill it**: `DISABLE_TELEMETRY=1` in `.env`.

5. **YOLO mode exists**: `--dangerously-skip-permissions` bypasses everything. RedCyberClaw's approach is better — explicit allow-lists for security tools with deny-lists for footguns.

6. **Skills are just markdown**: No sandboxing, no capability restriction. Whatever's in a SKILL.md, Claude will try to do. RedCyberClaw's packs leverage this fully.
