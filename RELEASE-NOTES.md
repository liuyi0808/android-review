# Android Review Release Notes

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
