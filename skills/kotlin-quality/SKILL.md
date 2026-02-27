---
name: kotlin-quality
description: >-
  Kotlin code quality review for Android projects. Covers coroutine structured
  concurrency, Flow operators, null safety, type design (sealed classes, data
  classes, value objects), and collection/functional patterns. Use when:
  reviewing Kotlin code in PRs, auditing coroutine usage, checking null safety
  patterns, evaluating type design decisions, or improving code readability
  and correctness.
---

# Kotlin Code Quality Review

Evaluate Kotlin code across five quality categories and produce structured findings with concrete fixes.

## Review Process

### Phase 1: Triage

Scan project structure (build.gradle, source tree, imports) to determine which categories apply. SKIP categories only when the skip condition is met.

| Category     | Skip If                                      |
|--------------|----------------------------------------------|
| Coroutines   | No `kotlinx-coroutines` dependency            |
| Flow         | No `import kotlinx.coroutines.flow` in source |
| Null Safety  | NEVER skip                                    |
| Type Design  | NEVER skip                                    |
| Collections  | NEVER skip                                    |

### Phase 2: Parallel Scan

Run all applicable categories in PARALLEL using independent Task agents. Each agent:

1. Grep for the category's anti-patterns (see search guide below)
2. Read matched files to confirm the finding is real
3. Return findings in the output format below

### Phase 3: Report

Merge parallel results into a single structured report, grouped by category and sorted by severity.

---

## Output Format

```
[KT-{CATEGORY}-{NNN}] severity: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <description>
  Location: <file:line>
  Fix: <concrete action>
```

---

## Reference Guide — Load on Demand

Each reference file contains detailed patterns, code examples, and rationale. **Read the relevant file when reviewing that category.**

| # | Reference File | Content | When to Load |
|---|---------------|---------|-------------|
| 1 | [references/coroutines.md](references/coroutines.md) | Structured concurrency, Scope, exception propagation, Dispatcher | Reviewing coroutine usage or async code |
| 2 | [references/flow.md](references/flow.md) | Cold/hot Flow, operators, stateIn/shareIn, lifecycle collection | Reviewing Flow usage or reactive streams |
| 3 | [references/null-safety.md](references/null-safety.md) | !! elimination, lateinit alternatives, safe casts, ?. chains | Reviewing null handling patterns |
| 4 | [references/type-design.md](references/type-design.md) | Sealed class/interface, data class, value class, generics | Reviewing type definitions or API design |
| 5 | [references/collections.md](references/collections.md) | Immutability, sequence vs list, scope functions | Reviewing collection operations or functional patterns |

---

## Anti-Pattern Search Guide

Grep-ready patterns per category. Only search categories that passed triage.

**Coroutines**

| Pattern | Detection Target | Severity |
|---------|-----------------|----------|
| `GlobalScope\.launch\|GlobalScope\.async` | GlobalScope misuse | CRITICAL |
| `CoroutineScope\(` not in class property | Temporary Scope leak | HIGH |
| `launch\s*\{` without try or CoroutineExceptionHandler | Exception swallowed | CRITICAL |
| `async\s*\{` without `.await()` | Result discarded | HIGH |
| `runBlocking\s*\{` not in main() or test | Blocks thread | CRITICAL |
| `Dispatchers\.IO` with CPU work (sort, serialize, encrypt) | Wrong Dispatcher | MEDIUM |
| `withContext\(Dispatchers\.Main\)` with I/O | Main thread I/O | CRITICAL |
| `delay\(` for polling instead of Flow | Manual polling | MEDIUM |

**Flow**

| Pattern | Detection Target | Severity |
|---------|-----------------|----------|
| `.collect\s*\{` in launch without `repeatOnLifecycle` | Background collection | HIGH |
| `stateIn\(` with `SharingStarted.Eagerly` | Wasteful hot flow | MEDIUM |
| `shareIn\(` vs `stateIn\(` confusion | Wrong sharing strategy | MEDIUM |
| `.catch\s*\{` after `.collect` | catch position wrong | HIGH |
| `.flowOn\(` after `.collect` | flowOn position wrong | HIGH |
| `MutableStateFlow` / `MutableSharedFlow` as public | Mutable flow exposed | HIGH |
| `flow \{` with side effects mixed with emit | Impure flow builder | LOW |

**Null Safety**

| Pattern | Detection Target | Severity |
|---------|-----------------|----------|
| `!!` | Non-null assertion risk | HIGH |
| `lateinit var` outside DI/lifecycle | Misused lateinit | HIGH |
| 3+ level `?.` chain | Null chain nesting | MEDIUM |
| `as\s+\w+` without `?` outside when | Unsafe cast | HIGH |
| `catch.*\{\s*\}` or `catch.*\{.*null` | Exception swallowed | CRITICAL |
| `.get\(` / `\[.*\]` on Map/List without safe access | Index/key crash | MEDIUM |

**Type Design**

| Pattern | Detection Target | Severity |
|---------|-----------------|----------|
| `when` + `else` on sealed types | Non-exhaustive | HIGH |
| 3+ same-type primitive parameters | Parameter confusion | MEDIUM |
| `data class` with `var` | Mutable data class | HIGH |
| `Pair<` / `Triple<` | Unnamed tuple | MEDIUM |
| `Any` as parameter/return | Type erasure | HIGH |
| enum with complex when branches | Should be sealed + polymorphism | LOW |
| `typealias` wrapping primitive | Should be value class | MEDIUM |

**Collections**

| Pattern | Detection Target | Severity |
|---------|-----------------|----------|
| Side effects in `.map\s*\{` (Log, println, network, DB) | Impure map | HIGH |
| 4+ chained operators without `asSequence()` | Multiple traversals | MEDIUM |
| Public `mutableListOf\|mutableMapOf\|mutableSetOf` | Mutable collection leak | HIGH |
| `for` loop replaceable by map/filter/fold | Imperative style | LOW |
| Scope function nesting >1 level | Readability loss | MEDIUM |
| `toMutableList()` modify-then-return | Should use buildList | LOW |

---

## Rules Summary

### Coroutines (6 rules)
1. NEVER use GlobalScope — bind to viewModelScope/lifecycleScope/custom scope with cancellation.
2. launch exceptions don't propagate — must handle via try/catch or CoroutineExceptionHandler.
3. async Deferred must be awaited — otherwise exceptions silently lost.
4. runBlocking only in main() and tests — forbidden in production.
5. Match Dispatcher to work type: IO for I/O, Default for CPU, Main for UI only.
6. Use supervisorScope to isolate child coroutine failures.

### Flow (5 rules)
1. UI collection must use repeatOnLifecycle or collectAsStateWithLifecycle.
2. MutableStateFlow/MutableSharedFlow must be private, expose as read-only.
3. catch only catches upstream — must precede collect.
4. flowOn only changes upstream Dispatcher — must precede collect.
5. stateIn for UI state (has initial value), shareIn for events (no replay).

### Null Safety (5 rules)
1. `!!` only when compiler can't infer but you can prove non-null — must have comment.
2. Prefer requireNotNull/checkNotNull over !! for meaningful errors.
3. lateinit only for DI and lifecycle — else use lazy or nullable.
4. Flatten null chains: max 2 levels of ?. — use early return or when.
5. Unsafe as only inside when type branches — else use as? + Elvis.

### Type Design (5 rules)
1. Sealed when must exhaust all subtypes — no else fallback.
2. 3+ same-type params must be wrapped in data class or use named arguments.
3. Data class fields must all be val.
4. Use value class over typealias for primitive wrappers.
5. No Pair/Triple in public API — use named data class.

### Collections (5 rules)
1. No side effects in map/filter/flatMap — use onEach/forEach.
2. Public properties expose immutable collections.
3. 3+ chained operators on large collections use asSequence().
4. Scope function nesting max 1 level.
5. Prefer buildList/buildMap/buildSet over toMutableX pattern.

---

## Checklists

### Coroutines
- [ ] No GlobalScope usage
- [ ] All launch blocks have exception handling
- [ ] All async Deferred values are awaited
- [ ] No runBlocking in production code
- [ ] Dispatcher matches work type (IO/Default/Main)
- [ ] CoroutineScope bound to lifecycle or has cancellation
- [ ] Child failures isolated with supervisorScope

### Flow
- [ ] UI collect uses repeatOnLifecycle or collectAsStateWithLifecycle
- [ ] MutableStateFlow/MutableSharedFlow are private
- [ ] catch precedes collect
- [ ] flowOn precedes collect
- [ ] stateIn for state, shareIn for events
- [ ] No side effects in flow {} builder

### Null Safety
- [ ] No unjustified !! usage
- [ ] lateinit only for DI and lifecycle
- [ ] No 3+ level ?. chain nesting
- [ ] Unsafe as only in when type branches
- [ ] No catch-and-return-null swallowing
- [ ] Map/List access uses safe methods (getOrNull/getOrElse)

### Type Design
- [ ] Sealed when exhausts all subtypes (no else)
- [ ] No 3+ same-type primitive parameters
- [ ] Data class fields all val
- [ ] No Pair/Triple in public API
- [ ] No Any as parameter or return type
- [ ] Primitive wrappers use value class not typealias

### Collections
- [ ] No side effects in map/filter
- [ ] Public properties expose immutable collections
- [ ] Large collection chains use asSequence
- [ ] Scope function nesting max 1 level
- [ ] Uses buildList/buildMap over toMutableX pattern

---

*For architecture patterns (ViewModel, UseCase, Repository), see the `architecture` skill. For Compose UI patterns, see the `compose-ui` skill. For performance optimization, see the `performance` skill.*
