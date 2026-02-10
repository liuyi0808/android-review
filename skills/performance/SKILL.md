---
name: performance
description: >-
  Audit Android (Kotlin/Compose) apps for performance issues and produce
  structured findings. Use when: app cold start exceeds 500ms, UI jank or
  dropped frames, memory leaks or OOM, ANR rate above 0.47% in Play Vitals,
  Compose recomposition waste, missing baseline profiles, battery drain,
  reviewing performance before release, or general performance optimization.
---

# Android Performance Audit

Produce a structured audit report with prioritized findings and concrete fixes.

## Audit Process

### Phase 1: Triage

Scan project structure (build.gradle, AndroidManifest.xml, source tree) to determine which categories apply. SKIP categories with no relevant code.

| Category | Skip If |
|----------|---------|
| Startup | No custom Application class, no splash screen |
| Recomposition | No Jetpack Compose (`@Composable` not found) |
| Memory | No ViewModel / Repository / singleton patterns |
| ANR | No SharedPreferences / BroadcastReceiver / sync I/O |
| Pagination | No list screens or large data sets |
| Baseline Profiles | NEVER skip — always relevant |
| Battery & Network | No background work, location, or network calls |

### Phase 2: Parallel Scan

Run all relevant categories in PARALLEL using independent Task agents. Each agent:

1. Grep for the category's anti-patterns (see search guide below)
2. Read matched files to confirm the finding is real
3. Return findings in the per-finding format below

### Phase 3: Report

Merge parallel results into the final report format below.

## Thresholds

| Metric | Target | Critical |
|--------|--------|----------|
| Cold start | < 500ms | > 1000ms |
| Warm start | < 300ms | > 600ms |
| Hot start | < 100ms | > 200ms |
| ANR rate | < 0.47% | > 1% |
| Crash rate | < 1.09% | > 2% |

## Anti-Pattern Search Guide

Grep-ready patterns per category. Only search categories that passed triage.

**Startup**
- `class \w+ : Application` → check `onCreate` body for heavy sync init
- `ContentProvider` in manifest → auto-init SDKs blocking startup
- Missing `reportFullyDrawn()` anywhere in codebase

**Recomposition**
- `List<` / `MutableList<` / `ArrayList<` in `@Composable fun` parameters → unstable type, use `ImmutableList` or `@Immutable` wrapper
- `{ viewModel.` or `{ \w+ViewModel.` inline in Composable call sites → lambda recreated every recomposition, extract with `remember`
- `items(` without `key =` in LazyColumn/LazyRow
- `.value` read outside `graphicsLayer` / `Modifier.layout` / `Modifier.drawBehind` → state read triggers full recomposition instead of layout/draw only
- Missing `composeCompiler { reportsDestination }` in build.gradle → no compiler metrics

**Memory**
- `context:` or `Context` field in ViewModel / Repository / `object` declaration → Activity leak
- `CoroutineScope(` without lifecycle-aware cancellation
- `companion object` or top-level `val` holding Activity/View/Fragment reference
- Object creation (`= Rect(` / `= Paint(` / `= StringBuilder(`) inside `for` / `while` loop body

**ANR**
- `.commit()` on SharedPreferences → blocks main thread, use `.apply()`
- Network/DB/File I/O call NOT wrapped in `withContext(Dispatchers.IO)` on a path reachable from main thread
- `BroadcastReceiver` subclass with `onReceive` body missing `goAsync()`

**Pagination**
- `Column {` followed by `.forEach` or `for (` → composes ALL items, use LazyColumn
- Large data source without Paging 3 integration

**Baseline Profiles**
- `profileinstaller` NOT in dependencies (build.gradle / libs.versions.toml)
- No `:baselineprofile` module or `BaselineProfileRule` test class

**Battery & Network**
- `AlarmManager` usage → should be WorkManager for deferrable work
- `OkHttpClient` without `.cache(` → missing HTTP cache
- Continuous location or sensor listener without interval / `removeUpdates`

## Output Format

### Per Finding

```
[PERF-{CATEGORY}-{NNN}] impact: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <root cause>
  Location: <file:line>        ← required for CRITICAL/HIGH only
  Fix: <concrete action>
  Metric: <expected improvement>
```

### Final Report

```markdown
## Performance Audit Report

### Summary
- Critical: N | High: N | Medium: N | Low: N
- Scanned: N/7 categories (skipped: <list with reasons>)

### Findings

#### Startup
[PERF-STARTUP-001] impact: CRITICAL
  Finding: Synchronous SDK init in Application.onCreate
  Location: App.kt:15
  Fix: Defer via App Startup library or lifecycle observer
  Metric: ~400ms cold start reduction

#### ...

### Metrics
| Metric | Estimated | Target | Status |
|--------|-----------|--------|--------|
| Cold start | Xms | <500ms | PASS/FAIL |
| ANR rate | X% | <0.47% | PASS/FAIL |
```
