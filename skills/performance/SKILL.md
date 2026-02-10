---
name: performance
description: >-
  Android application performance optimization guidance. Use when: app startup is
  slow (cold start >500ms), UI has jank or dropped frames, memory leaks or OOM
  crashes occur, ANR issues appear, Jetpack Compose has excessive recomposition,
  battery drain is reported, Play Vitals shows poor metrics, setting up baseline
  profiles, optimizing LazyColumn/pagination, or reviewing image loading strategy.
---

# Android Performance Optimization

Identify and resolve performance issues in Android (Kotlin/Compose) applications.

## Performance Audit Process

Evaluate code against ALL categories. Output findings as:

```
[PERF-XXXXX] impact: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <what causes the performance issue>
  Location: <file:line>
  Fix: <concrete optimization>
  Metric: <expected improvement>
```

---

## 1. App Startup

### Three Startup Types

| Type | Definition | Target |
|------|-----------|--------|
| Cold | Process not running, app launched from scratch | < 500ms |
| Warm | Process alive, Activity recreated | < 300ms |
| Hot | Activity in memory, brought to foreground | < 100ms |

---

## Reference Guide — Load on Demand

Each reference file contains full code examples and patterns. **Read the relevant file when optimizing that area.**

| # | Reference File | Content | When to Load |
|---|---------------|---------|-------------|
| 1 | [references/startup.md](references/startup.md) | App Startup library, SplashScreen API, deferred init, measurement | Cold start optimization |
| 2 | [references/recomposition.md](references/recomposition.md) | Stable/Immutable types, lambda extraction, key(), deferred reads, derivedStateOf | Compose jank or recomposition issues |
| 3 | [references/memory.md](references/memory.md) | Context leaks, coroutine cancellation, WeakReference, LeakCanary | Memory leaks or OOM crashes |
| 4 | [references/anr.md](references/anr.md) | Dispatcher usage, SharedPreferences, BroadcastReceiver offloading | ANR issues in Play Vitals |
| 5 | [references/lazy-and-pagination.md](references/lazy-and-pagination.md) | Paging 3, LazyColumn, Coil image loading | List performance or pagination |
| 6 | [references/baseline-profiles.md](references/baseline-profiles.md) | Complete baseline profile setup and generation | Release build optimization |
| 7 | [references/battery.md](references/battery.md) | WorkManager, caching, doze mode, network batching | Battery drain or network optimization |

---

## Rules Summary

### Startup
1. NEVER do heavy work in `Application.onCreate()`.
2. Use `App Startup` library for lazy initialization.
3. Avoid splash screen blocking — use `SplashScreen` API.
4. Measure startup time; call `reportFullyDrawn()`.

### Compose Recomposition
1. Use `Stable` and `Immutable` types to prevent unnecessary recomposition.
2. Extract lambdas to prevent recomposition.
3. Use `key()` for lists to enable efficient diffing.
4. Defer reads to narrow recomposition scope.
5. Use `derivedStateOf` for computed values.
6. Enable Compose compiler metrics for CI.

### Memory Management
1. NEVER hold Activity/Context references in long-lived objects.
2. Cancel coroutines when scope is destroyed.
3. Use `WeakReference` for callbacks that may outlive the holder.
4. Avoid creating objects in tight loops.
5. Monitor with LeakCanary in debug builds.

### ANR Prevention
1. NEVER perform I/O, network, or heavy computation on main thread.
2. Move work to coroutines with appropriate dispatcher (`IO`, `Default`).
3. Use `apply()` not `commit()` for SharedPreferences.
4. BroadcastReceiver must finish within 10 seconds.

### Lazy Loading & Pagination
1. Use Paging 3 for large data sets.
2. Use `LazyColumn`/`LazyRow` for lists (NEVER `Column` + `forEach` for large lists).
3. Use Coil/Glide with proper caching for images.

### Baseline Profiles
1. Add `profileinstaller` dependency.
2. Create baseline profile generator covering critical paths.
3. Include profile in release build.

### Battery & Network
1. Batch network requests.
2. Use WorkManager for deferrable background work.
3. Respect doze mode.
4. Cache aggressively (OkHttp cache + Room).

---

## Checklists

### Startup
- [ ] No synchronous network calls in Application/Activity.onCreate
- [ ] SDK initialization deferred or lazy
- [ ] Content provider initialization reviewed (auto-init SDKs)
- [ ] `reportFullyDrawn()` called after meaningful content displayed
- [ ] Startup trace profiled with Android Studio Profiler

### Compose Recomposition
- [ ] No unstable parameters in frequently recomposed functions
- [ ] LazyColumn/LazyRow use `key` parameter
- [ ] State reads deferred to layout/draw phase where possible
- [ ] No allocations inside Composable functions (use remember)
- [ ] Compose compiler metrics reviewed (no unexpected restartable groups)

### Memory Management
- [ ] No Activity/Fragment context in ViewModel or Repository
- [ ] Coroutines cancelled on scope destruction
- [ ] No static references to Activity/View
- [ ] LeakCanary integrated in debug builds
- [ ] Large bitmaps properly sampled and recycled
- [ ] No unbounded caches

### ANR Prevention
- [ ] No synchronous I/O on main thread
- [ ] SharedPreferences uses apply(), not commit()
- [ ] BroadcastReceiver offloads work
- [ ] StrictMode enabled in debug to catch violations
- [ ] ANR rate below 0.47% in Play vitals

### Lazy Loading & Pagination
- [ ] Paging 3 used for large data sets
- [ ] LazyColumn/LazyRow for all scrollable lists
- [ ] Images loaded with Coil/Glide (cached)

### Baseline Profiles
- [ ] `profileinstaller` dependency added
- [ ] Baseline profile generator covers critical paths
- [ ] Profile generated and included in release build
- [ ] Startup time measured before/after profile

### Battery & Network
- [ ] No wake locks held longer than necessary
- [ ] Background work uses WorkManager (not AlarmManager)
- [ ] Network requests batched and cached
- [ ] Location updates use appropriate interval and accuracy
- [ ] No continuous sensor polling

---

## Audit Output Format

```markdown
## Performance Audit Report

### Summary
- Critical: X | High: X | Medium: X | Low: X

### Findings
#### [CRITICAL] PERF-STARTUP-001: Synchronous SDK init in Application.onCreate
- File: App.kt:15
- Impact: +400ms cold start time
- Fix: Defer to background thread or lazy init

### Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Cold start | 1200ms | <500ms | FAIL |
| ANR rate | 0.8% | <0.47% | FAIL |
| Crash rate | 0.5% | <1.09% | PASS |
| Memory peak | 180MB | <150MB | WARNING |
```
