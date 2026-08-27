# Android Review — Agent Guide

Expert-level Android code review across seven domains: architecture, Compose UI,
Kotlin quality, performance, security, privacy compliance, and Google Play
compliance. Each domain is a self-contained skill under `skills/<name>/`, driven
by a `SKILL.md` with detailed reference docs loaded on demand.

This file is the entry point for Codex CLI and any agent that reads `AGENTS.md`.
The same skills also ship as a Claude Code plugin (see `.claude-plugin/`).

## Skills

Each skill lives in `skills/<name>/SKILL.md`. Load the matching skill when the
task fits its trigger, then read files under that skill's `references/` only when
the review reaches that topic (progressive disclosure — do not preload everything).

| Skill | Path | Load when |
|-------|------|-----------|
| architecture | `skills/architecture/SKILL.md` | Designing app structure; creating ViewModel/Repository/UseCase; setting up Hilt DI; planning module boundaries; reviewing layer dependencies; offline-first data; error-handling strategy; starting a new feature module. |
| compose-ui | `skills/compose-ui/SKILL.md` | Writing or reviewing Compose UI; state hoisting; side effects (LaunchedEffect, DisposableEffect); type-safe navigation; responsive layouts; accessibility; animations; reusable composables. |
| kotlin-quality | `skills/kotlin-quality/SKILL.md` | Reviewing Kotlin in PRs; auditing coroutine/structured concurrency; Flow operators; null safety; type design (sealed/data/value classes); collection & functional patterns. |
| performance | `skills/performance/SKILL.md` | Cold start > 500ms; UI jank; memory leaks/OOM; ANR rate > 0.47%; recomposition waste; missing baseline profiles; battery drain; pre-release performance review. |
| play-store | `skills/play-store/SKILL.md` | Pre-submission Google Play compliance; permissions; Data Safety; Financial Features Declaration / loan apps; sensitive-permission and spyware policy; account deletion; code-level audit. Updated for the 2025-2026 policy cycle. |
| privacy-audit | `skills/privacy-audit/SKILL.md` | Three-way privacy compliance audit for loan apps: privacy policy vs in-app disclosure dialogs vs code implementation; banned loan-app permissions; READ_SMS filtering; third-party SDK data sharing. Runs a fixed 5-step workflow and writes a report file. |
| security-audit | `skills/security-audit/SKILL.md` | Sensitive-data storage; cryptography/Keystore; authentication/biometrics; network security (TLS, cert pinning); WebView hardening; Content Provider security; RE resilience; user privacy. OWASP MASVS v2.0. |

## How reviews work

Each skill runs a structured audit and emits findings with a domain prefix and
severity, for example:

```
[ARCH-LAYER-001] severity: HIGH
location: data/repository/UserRepositoryImpl.kt:42
issue: Domain layer imports Android framework class (android.content.Context)
fix: Inject an interface that wraps Context-dependent operations
```

Prefixes: `[ARCH-*]`, `[COMPOSE-*]`, `[KT-*]`, `[PERF-*]`, `[GP-*]`,
severity-based output for security-audit, and a written three-way comparison
report (`privacy-audit-report-[YYYY-MM-DD].md`) for privacy-audit.

## Scripts

- `skills/play-store/scripts/audit.sh` — automated grep-based Play Store audit.
  Run it from the target Android project root; it flags manifest, permission, and
  build-config issues for the play-store skill to interpret.

## Setup

- Codex CLI: `codex plugin marketplace add https://github.com/liuyi0808/android-review`
  then `codex plugin add android-review@android-review`, then restart Codex. Or
  reference this `AGENTS.md` directly from a project that vendors this repo.
- Claude Code: `claude plugin marketplace add liuyi0808/android-review` then
  `claude plugin install android-review`.

The `skills/` directory is the single source of truth for both platforms.
