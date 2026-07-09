# Android Review Release Notes

## v1.6.0 (2026-07-09)

### Codex CLI Support — Dual-Platform Skills

The six review skills now work with **Codex CLI** in addition to Claude Code. No skill content changed — `skills/` remains the single source of truth for both platforms. The skills were already vendor-neutral (`SKILL.md` + `references/`, no Claude-specific hooks or tooling), so support was additive.

**New — `AGENTS.md` (repo root)**:
- Agent-facing entry point for Codex CLI and any agent that reads `AGENTS.md`.
- Table mapping each skill to its `skills/<name>/SKILL.md` path and its load-when trigger, derived from each skill's own frontmatter `description`.
- Documents the findings prefixes (`[ARCH-*]`, `[COMPOSE-*]`, `[KT-*]`, `[PERF-*]`, `[GP-*]`, severity-based), the `play-store/scripts/audit.sh` helper, and setup for both platforms.
- States progressive disclosure explicitly: load the matching skill, then read its `references/` only when the review reaches that topic.

**New — `scripts/install-codex.sh`**:
- Links each `skills/<name>/` folder into `~/.codex/skills/` so Codex auto-discovers them on restart.
- Symlinks by default (a `git pull` then updates Codex with no reinstall); `--copy` copies instead; honors `CODEX_HOME` override.
- Idempotent — re-runs cleanly by removing any prior install first.

**`README.md`**:
- Reframed from "a Claude Code plugin" to dual-platform (Claude Code + Codex CLI), with `skills/` called out as the shared source of truth.
- Installation split into Claude Code and Codex CLI sections.
- Structure tree adds `AGENTS.md` and `scripts/install-codex.sh`; Requirements now reads "Claude Code CLI **or** Codex CLI".

**Unchanged**: `scripts/release.sh` still syncs only the `.claude-plugin/` version fields — the Codex-side files carry no version string, so the release flow needs no change.

## v1.5.0 (2026-05-18)

### Play Store Skill — Outcome-vs-Implementation Audit Contract

Root cause addressed: prior audits packaged engineering preferences (sender allow-lists, specific APIs, SP-key guards, server-side filters) as if Google Play policy required them, and judged code patterns (`READ_SMS + uploadInfo`) as violations without checking declaration status or actual transmission outcome. v1.5.0 makes both gates structurally mandatory in the Output Format — a finding that fails either gate is invalid and must be rejected by the main agent.

**SKILL.md — Rule 6 added (Five Rules → Six Rules)**:
- Every finding must answer two structural questions: (a) does this policy have a declaration channel (Permissions Declaration, Data Safety, Financial Declaration), and (b) does the `Required by policy:` field contain verbatim policy text rather than prescribed implementation.
- New severity `NEEDS_CONFIRMATION` for declaration-gated policies where the developer's declaration status is unknown to the auditor. Reported in a separate section, never tallied with BLOCKER/WARNING/INFO.
- Output Format extended from 6 fields to 11 mandatory fields — adds `Declaration Channel`, `Declaration Status`, `Required by policy` (verbatim quote), `Suggested implementation` (must be prefixed "non-policy, auditor's suggestion only").
- Main agent hard constraints: drop findings missing reference/policy URL; downgrade declaration-gated findings with unknown status; move prescriptive implementation language out of `Required by policy`.
- Two example blocks: Example A (absolute prohibition, no declaration channel — direct BLOCKER) and Example B (declaration-gated policy, status unknown — NEEDS_CONFIRMATION).
- "Common Rejection Reasons" table re-framed as a quick reference, not a finding template; loan-harassment and SMS spyware rows rewritten to separate outcome from implementation.

**spyware-policy.md §11.4 — single-severity model replaced by two-gate model**:
- Gate 1 (Permissions Declaration / right to use READ_SMS) and Gate 2 (Spyware Cat.4 / actually-exfiltrated content) are independent. Final verdict = the more severe of the two.
- "Recommended Practices" split into **Policy Requirements** (BLOCKER if violated) and **Engineering Suggestions** (auditor's preference, NOT severity inputs).
- Background context (approval rates, industry direction, body-vs-metadata) explicitly demoted to informational — must not raise severity.
- Detection grep patterns relabeled "Auditor Tooling" — presence is not violation, absence is not compliance.
- Maintenance note updated to flag any future Google prescription of HOW (sender lists, filtering mechanisms) as a policy-shape change.

**loan-harassment.md 14.3 — checklist alignment**:
- SMS bullet rewritten to point at the spyware-policy.md two-gate model. Financial SMS use for lending decisions is NOT prohibited per se — only non-financial/personal SMS exfiltration is.
- `QUERY_ALL_PACKAGES` bullet split: the permission itself is banned for loan apps; targeted `<queries>` blocks are allowed but credit-assessment use cases are flagged as developer-review risk, not direct BLOCKER.

**code-audit.md + scripts/audit.sh — detection severity downgraded**:
- SMS body upload, incremental SMS harvesting, and SQL LIKE patterns near SMS code are detection patterns only. They locate paths to investigate; they do not establish violation.
- `audit.sh` SMS-related checks downgraded from `WARNING` to `INFO` with a pointer to the two-gate review in spyware-policy.md §11.4.

**Why this release matters**: An audit skill that cannot distinguish "policy says X" from "auditor prefers X" produces unactionable findings — the developer cannot tell which item Google will actually reject on, and which is just engineering opinion. The Output Format change makes that distinction visible per finding.

## v1.4.0 (2026-04-23)

### Play Store Skill — Loan App Focus Cleanup + Universal Policy Coverage + Execution Contract

Three-part release. Part A removes policy sections that do not apply to personal loan apps. Part B adds the two universal policies that apply to all apps and were previously missing. Part C introduces an Execution Contract that forces full reference coverage and traceable findings.

**Part A — Redundancy cleanup (non-applicable policy sections removed based on scope defined in each official policy)**:
- Remove `store-listing.md 9.3 Age-Restricted Content` — policy scope is matchmaking/dating/real money gambling
- Remove `deceptive-behavior.md 10.8 Families Policy & Child Safety Standards` — policy scope is apps targeting children / Social or Dating apps
- Remove `deceptive-behavior.md 10.9 User-Generated Content` — policy scope is apps hosting UGC
- Remove `financial-declaration.md 4.4.1 Cryptocurrency / Blockchain` — policy scope is crypto exchanges/wallets/NFTs
- Remove "No mining cryptocurrency in background" line from `device-abuse.md 12.4` — not relevant to loan apps
- Simplify `permissions.md 3.7 Exact Alarm` to a one-line prohibition for loan apps
- Simplify `permissions.md 3.8 Full-Screen Intent` to a one-line prohibition for loan apps
- Remove Age-Restricted row from `SKILL.md` Key Policy Deadlines table

**Part B — Universal policies added (verbatim from official policy text)**:
- Add `references/intellectual-property.md` — Core prohibition, trademark, copyright, counterfeit, encouraging infringement, plus financial-app brand-misuse risk table. Sourced from the official [Intellectual Property policy](https://support.google.com/googleplay/android-developer/answer/9888072).
- Add `references/restricted-content.md` — Child endangerment, sexual content, hate speech, violence, violent extremism, sensitive events, bullying/harassment, dangerous products, marijuana, tobacco/alcohol. Sourced from the official [Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/16810878). Includes loan-app surfaces (strings, notifications, support scripts).
- Update `SKILL.md` reference table to 14 files, extend Launch Day Checklist Policy section, add 3 rejection rows to Common Rejection Reasons table, add 2 official references.

**Part C — Execution Contract (enforce full reference coverage)**:

Root cause addressed: prior versions allowed the auditor to silently skip reference files, leading to incomplete audits being reported as complete. v1.4.0 makes every reference file load observable and every finding traceable to its source.

- Add `## Execution Contract` at the top of SKILL.md with 5 rules — all 14 references MUST be loaded, parallel execution is the default, every finding must cite its reference, Coverage Report is mandatory, no conclusions from memory.
- Add `## Parallel Execution Pattern` — 5 subagent groups (A–E) each owning 2–3 reference files, with a subagent prompt template. Main agent merges, deduplicates, sorts, and produces the Coverage Report.
- Rewrite `## Pre-Submission Audit Process` with a new Output Format that adds two mandatory fields:
  - `Reference: <file>#<section anchor>`
  - `Policy Source: <official Google Play URL>`
  A finding missing either field is invalid and must be rejected by the main agent.
- Rename `Reference Guide — Load on Demand` → `Reference File Index (all 14 must be loaded for a full audit)`. Add a `Subagent Group` column so each reference maps to its owning subagent.
- Add `## Reference Coverage Report` section with a 14-row table template. Three status values: `✅`, `⏭ Not Applicable` (with reason), `❌ Skipped` (flags the audit as incomplete).

## v1.3.0 (2026-04-22)

### Play Store Skill — April 15, 2026 Policy Update
- Add new `3.9 Contacts Permissions` section covering the Contacts Permissions Policy (effective 2026-10-28, Android 17+ / API 37+) — Android Contact Picker mandatory for non-broad access
- Update `3.4 Location Permissions` with the `onlyForLocationButton` flag (effective ~2026-05-15) and Play Developer Declaration path for persistent precise location
- Update `3.6 Foreground Service Types` to flag geofencing as removed from approved FGS use cases; direct developers to the Geofence API
- Note April 15, 2026 clarification on Photo & Video permissions in `3.3`
- Strengthen `loan-harassment.md 14.1` with the double-violation warning — Contact Picker does NOT make loan-app contact collection permissible
- Add new grep patterns in `code-audit.md` for direct `ContactsContract` queries, `onlyForLocationButton`, and geofencing-via-FGS
- Add 3 new deadline rows to `SKILL.md` Section 21 (2026-05-15, 2026-10-27, 2026-10-28)
- Add 3 new rejection reasons to Section 20 (broad contacts, precise location w/o button, geofencing via FGS)
- Add 4 official references (April 15 announcement, minimum-scope alternatives, Contact Picker blog, Location Privacy blog)

## v1.2.0 (2026-03-31)

### Play Store Skill — Policy Verification Overhaul
- Align SMS/Call Log policy with 2025-2026 Google Play requirements
- Verify and update all policy references against official documentation
- Correct 12 factual errors found in policy verification audit
- Address second-round verification findings
- Deep policy verification — 24 substantive corrections across play-store skill

## v1.1.0 (2026-02-12)

### Improvements
- Rewrite performance skill for 6.7x faster audit execution
- Apply progressive disclosure to all skills — reference files loaded on demand
- Split play-store skill into 12 modular reference files
- Overhaul play-store skill with 2025-2026 policy updates
- Patch GAP-04, GAP-05, GAP-08 in play-store skill

### Infrastructure
- Publish to GitHub as Claude Code plugin
- Add `scripts/release.sh` for versioned releases
- Add GitHub Actions workflow for automated releases

## v1.0.0 (2026-02-10)

Initial release with 5 review skills:

- **architecture** — Clean Architecture, MVVM/MVI, Hilt DI, modularization
- **compose-ui** — Jetpack Compose, Material 3, accessibility, animations
- **performance** — Startup, recomposition, memory, ANR, battery audit
- **play-store** — Google Play compliance, financial app declarations, spyware policy
- **security-audit** — OWASP MASVS v2.0, 8 categories, 51 checklist items
