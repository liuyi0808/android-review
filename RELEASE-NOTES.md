# Android Review Release Notes

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
