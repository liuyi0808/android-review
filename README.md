# Android Review

Expert-level Android code review across seven domains: architecture, Compose UI, Kotlin quality, performance, security, privacy compliance, and Google Play compliance. Each skill runs a structured audit, searches for anti-patterns, and produces actionable findings with severity ratings.

Works with both **Claude Code** (as a plugin) and **Codex CLI** (as skills). The `skills/` directory is the single source of truth for both — see [AGENTS.md](AGENTS.md) for the agent-facing guide.

Built for Android teams writing Kotlin and Jetpack Compose.

## Skills

| Skill | What it audits | Output prefix |
|-------|---------------|---------------|
| **architecture** | Clean Architecture layers, MVVM/MVI, Hilt DI, modularization, error handling | `[ARCH-*]` |
| **compose-ui** | State management, side effects, navigation, Material 3 theming, accessibility | `[COMPOSE-*]` |
| **kotlin-quality** | Coroutines, Flow, null safety, type design, collections & functional patterns | `[KT-*]` |
| **performance** | Startup time, recomposition waste, memory leaks, ANR, battery drain | `[PERF-*]` |
| **play-store** | Build config, permissions, Data Safety, financial app declarations, spyware policy | `[GP-*]` |
| **privacy-audit** | Privacy policy vs in-app disclosure vs code — three-way consistency for loan apps | Report file |
| **security-audit** | OWASP MASVS v2.0 — storage, crypto, auth, network, platform, code, resilience, privacy | Severity-based |

Each skill uses progressive disclosure: a concise SKILL.md drives the review process, with detailed reference files loaded only when the audit reaches that topic.

## Installation

### Claude Code

```bash
claude plugin marketplace add liuyi0808/android-review
claude plugin install android-review
```

Verify by starting a new Claude Code session. The seven skills should appear in the available skills list.

Update with:

```bash
claude plugin marketplace update android-review
claude plugin update android-review
```

### Codex CLI

```bash
codex plugin marketplace add https://github.com/liuyi0808/android-review
codex plugin add android-review@android-review
```

Restart Codex CLI and confirm the seven skills appear in its available-skills list.

Alternatively, point Codex at the repo directly via the root [AGENTS.md](AGENTS.md), which documents when each skill applies.

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

```
Run a privacy compliance audit on this loan app
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
├── AGENTS.md                    # Agent-facing guide (Codex CLI + generic agents)
├── .claude-plugin/
│   ├── plugin.json              # Claude Code plugin metadata
│   └── marketplace.json         # Claude Code marketplace registration
├── .github/
│   └── workflows/
│       └── release.yml          # Auto-create GitHub Release on tag push
├── scripts/
│   └── release.sh               # Version bump + tag + push
├── skills/                      # Single source of truth for both platforms
│   ├── architecture/
│   │   ├── SKILL.md             # Clean Architecture, MVVM/MVI, Hilt DI
│   │   └── references/          # 6 detailed reference docs
│   ├── compose-ui/
│   │   ├── SKILL.md             # Jetpack Compose, Material 3
│   │   └── references/          # 5 detailed reference docs
│   ├── kotlin-quality/
│   │   ├── SKILL.md             # Coroutines, Flow, null safety, types, collections
│   │   └── references/          # 5 detailed reference docs
│   ├── performance/
│   │   └── SKILL.md             # 7-category performance audit
│   ├── play-store/
│   │   ├── SKILL.md             # Google Play compliance (2025-2026)
│   │   ├── scripts/audit.sh     # Automated grep-based audit script
│   │   └── references/          # 12 detailed reference docs
│   ├── privacy-audit/
│   │   ├── SKILL.md             # Three-way privacy compliance audit (loan apps)
│   │   └── references/          # Google Play policy digest + report template
│   └── security-audit/
│       ├── SKILL.md             # OWASP MASVS v2.0 audit
│       └── references/          # 8 detailed reference docs
├── RELEASE-NOTES.md
├── LICENSE
└── README.md
```

## Skill Details

### architecture

Reviews Android app structure against Clean Architecture standards.

**Checks:**
- Three-layer dependency rule (Presentation -> Domain -> Data, never reversed)
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

### kotlin-quality

Reviews Kotlin code for idiomatic patterns, safety, and correctness across five categories.

**Checks:**
- Coroutines: no `GlobalScope`, structured concurrency, exception handling, Dispatcher matching
- Flow: lifecycle-aware collection, `MutableStateFlow` encapsulation, `catch`/`flowOn` positioning
- Null safety: no unjustified `!!`, `lateinit` restrictions, safe casts, flattened null chains
- Type design: exhaustive sealed `when`, `value class` wrappers, immutable `data class`, no `Pair` in API
- Collections: no side effects in `map`, immutable public collections, `asSequence()` for large chains

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

Comprehensive pre-submission audit covering 18+ Google Play policy areas. Updated for the 2025-2026 policy cycle (policy effective date: March 4, 2026).

**Key deadlines tracked:**

| Deadline | Policy |
|----------|--------|
| May 28, 2025 | Photo/Video permissions full compliance; line of credit → Personal Loan policy |
| August 31, 2025 | Target API 35 for new apps and updates |
| November 1, 2025 | API 35 extension deadline (no more extensions) |
| January 2026 | Age Signals API, Accessibility API autonomous action, India loan app list |
| March 4, 2026 | Updated Developer Program Policies full enforcement |
| May 15, 2026 | Location button, Geofencing removed from FGS (April 15, 2026 announcement) |
| October 28, 2026 | Contacts Permissions policy — Contact Picker required (Android 17+) |

**Special coverage for financial/loan apps:** Financial Features Declaration, Personal Loan policy, loan harassment, predatory lending, prohibited credit scoring data, country-specific rules (India, Thailand).

**Output uses three severity levels:** `BLOCKER` (will cause rejection), `WARNING` (risk of rejection), `INFO` (recommendation).

### privacy-audit

Runs a "three-way comparison" for loan apps, verifying that the **privacy policy**, the **in-app disclosure dialogs**, and the **code implementation** all agree. Where `play-store` audits an app against Google Play policy, `privacy-audit` audits an app against its own published privacy promises.

**Fixed 5-step workflow** — the order is mandatory, and reading the privacy policy before the code scan invalidates the audit:

| Step | What happens |
|------|--------------|
| 1 | Scan the code — manifest, build files, strings, API request bodies, data models, SDK init |
| 2 | Ask the user which privacy policy source to use (never auto-use a URL found in code) |
| 3 | Fetch the policy (WebFetch, Playwright MCP fallback, or a local file) |
| 4 | Bidirectional comparison against the scan results |
| 5 | Write `privacy-audit-report-[YYYY-MM-DD].md` in the mandated structure |

**Comparison is bidirectional:** data collected in code but not disclosed is a `BLOCKER`; data declared in the policy but never collected is a `WARNING` (over-promising). A generic phrase such as "hardware information" does not count as explicit disclosure.

**Also checks:** permissions banned for loan apps (`READ_CONTACTS`, `QUERY_ALL_PACKAGES`, `ACCESS_FINE_LOCATION`, …), READ_SMS keyword filtering, `queries` tag scope, third-party SDK data sharing, and privacy policy quality (retention, deletion, contact details).

Step 3 falls back to Playwright MCP when `WebFetch` cannot render the policy page; without it, paste the policy text or pass a local file instead.

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

## Releasing

Versions follow [semver](https://semver.org/). The `plugin.json` version, git tag, and GitHub Release are kept in sync.

**To release a new version:**

```bash
./scripts/release.sh 1.2.0
```

This will:
1. Validate you are on `main` with a clean working tree
2. Bump the version in `plugin.json` and `marketplace.json`
3. Commit, tag `v1.2.0`, and push
4. GitHub Actions automatically creates a Release from the tag

See [RELEASE-NOTES.md](RELEASE-NOTES.md) for the full changelog.

## Requirements

- Claude Code CLI **or** Codex CLI
- An Android project using Kotlin and Jetpack Compose

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Skill files live under `skills/<skill-name>/`. Each skill has a `SKILL.md` that drives the review and a `references/` directory for detailed guidance.

## License

MIT
