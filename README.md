# Android Review

A Claude Code plugin that provides expert-level Android code review across five domains: architecture, Compose UI, performance, security, and Google Play compliance. Each skill runs a structured audit, searches for anti-patterns, and produces actionable findings with severity ratings.

Built for Android teams writing Kotlin and Jetpack Compose.

## Skills

| Skill | What it audits | Output prefix |
|-------|---------------|---------------|
| **architecture** | Clean Architecture layers, MVVM/MVI, Hilt DI, modularization, error handling | `[ARCH-*]` |
| **compose-ui** | State management, side effects, navigation, Material 3 theming, accessibility | `[COMPOSE-*]` |
| **performance** | Startup time, recomposition waste, memory leaks, ANR, battery drain | `[PERF-*]` |
| **play-store** | Build config, permissions, Data Safety, financial app declarations, spyware policy | `[GP-*]` |
| **security-audit** | OWASP MASVS v2.0 — storage, crypto, auth, network, platform, code, resilience, privacy | Severity-based |

Each skill uses progressive disclosure: a concise SKILL.md drives the review process, with detailed reference files loaded only when the audit reaches that topic.

## Installation

```bash
claude plugin marketplace add liuyi0808/android-review
claude plugin install android-review
```

Verify by starting a new Claude Code session. The five skills should appear in the available skills list.

## Updating

```bash
claude plugin marketplace update android-review
claude plugin update android-review
```

## Usage

Skills are invoked automatically when Claude Code detects a matching context, or you can trigger them directly:

```
Review the architecture of this project
```

```
Run a security audit on the authentication module
```

```
Check this app for Play Store compliance
```

```
Audit Compose UI code in the feature/home module
```

```
Run a performance audit — cold start is over 1 second
```

### What a review looks like

Each skill produces structured findings:

```
[ARCH-LAYER-001] severity: HIGH
location: data/repository/UserRepositoryImpl.kt:42
issue: Domain layer imports Android framework class (android.content.Context)
fix: Inject an interface that wraps Context-dependent operations
```

```
[PERF-STARTUP-003] impact: CRITICAL
location: MyApplication.kt:18
issue: Synchronous database init in Application.onCreate blocks cold start
fix: Move to background thread or use App Startup lazy initialization
```

```
[GP-PRIVACY-002] status: BLOCKER
location: AndroidManifest.xml
issue: READ_CONTACTS permission declared but not listed in Data Safety form
fix: Either remove the permission or update the Data Safety declaration
```

## Structure

```
android-review/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace registration
├── skills/
│   ├── architecture/
│   │   ├── SKILL.md             # Clean Architecture, MVVM/MVI, Hilt DI
│   │   └── references/          # 6 detailed reference docs
│   ├── compose-ui/
│   │   ├── SKILL.md             # Jetpack Compose, Material 3
│   │   └── references/          # 5 detailed reference docs
│   ├── performance/
│   │   └── SKILL.md             # 7-category performance audit
│   ├── play-store/
│   │   ├── SKILL.md             # Google Play compliance (2025-2026)
│   │   ├── scripts/audit.sh     # Automated grep-based audit script
│   │   └── references/          # 12 detailed reference docs
│   └── security-audit/
│       ├── SKILL.md             # OWASP MASVS v2.0 audit
│       └── references/          # 8 detailed reference docs
├── LICENSE
└── README.md
```

## Skill Details

### architecture

Reviews Android app structure against Clean Architecture standards.

**Checks:**
- Three-layer dependency rule (Presentation → Domain → Data, never reversed)
- One ViewModel per screen with immutable UiState
- Single-purpose UseCases with `operator fun invoke`
- Repository pattern with separate DTO/Entity/Domain Model mappers
- Hilt scoping (`@Binds` vs `@Provides`, correct `@InstallIn`)
- Module boundaries and circular dependency detection
- Error handling via `Result<T>` with domain exception mapping

### compose-ui

Reviews Jetpack Compose code against Material 3 best practices.

**Checks:**
- State hoisting and `collectAsStateWithLifecycle` usage
- Side effect correctness (LaunchedEffect keys, DisposableEffect cleanup)
- Type-safe navigation (Navigation Compose 2.8+)
- Theming compliance (no hardcoded colors, dark theme, dynamic colors)
- Accessibility (content descriptions, 48dp touch targets, 4.5:1 contrast)
- Animation API selection and reduced-motion support
- Composable function signature conventions

### performance

Runs a 3-phase audit: triage applicable categories, parallel anti-pattern scan, structured report.

**Categories and thresholds:**

| Metric | Target | Critical |
|--------|--------|----------|
| Cold start | < 500 ms | > 1000 ms |
| Warm start | < 300 ms | > 600 ms |
| ANR rate | < 0.47% | > 1% |
| Crash rate | < 1.09% | > 2% |

**Scans for:** heavy `Application.onCreate`, unstable Compose parameters, Context leaks in singletons, `SharedPreferences.commit()` on main thread, missing Paging 3, absent baseline profiles, AlarmManager misuse.

### play-store

Comprehensive pre-submission audit covering 18+ Google Play policy areas. Updated for the 2025-2026 policy cycle.

**Key deadlines tracked:**
- Target API 35 — August 2025
- Financial Features Declaration — October 2025
- Developer verification — September 2026

**Special coverage for financial/loan apps:** Financial Features Declaration, Personal Loan policy, loan harassment, predatory lending, prohibited credit scoring data.

**Output uses three severity levels:** `BLOCKER` (will cause rejection), `WARNING` (risk of rejection), `INFO` (recommendation).

### security-audit

Audits against all 8 OWASP MASVS v2.0 categories with CWE references.

**Categories (51 checklist items):**
- **STORAGE** — EncryptedSharedPreferences, no plaintext secrets, backup restrictions
- **CRYPTO** — AES-256-GCM via Keystore, no hardcoded keys, unique IVs
- **AUTH** — Biometric CryptoObject, short-lived tokens, session invalidation
- **NETWORK** — Certificate pinning, no TrustManager bypass, TLS 1.2+
- **PLATFORM** — Exported component permissions, PendingIntent immutability, WebView hardening
- **CODE** — R8 enabled, log guards, no debug artifacts in release
- **RESILIENCE** — Root/debugger/tamper detection, Play Integrity API
- **PRIVACY** — Data minimization, granular consent, GDPR/CCPA deletion

## Requirements

- Claude Code CLI
- An Android project using Kotlin and Jetpack Compose

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Skill files live under `skills/<skill-name>/`. Each skill has a `SKILL.md` that drives the review and a `references/` directory for detailed guidance.

## License

MIT

## Author

liuyi

## Version

1.0.0
