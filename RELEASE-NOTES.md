# Android Review Release Notes

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
