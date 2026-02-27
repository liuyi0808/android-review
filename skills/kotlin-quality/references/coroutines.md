# Coroutines

## GlobalScope vs Lifecycle-Bound Scope

```kotlin
// BAD: No lifecycle binding, continues after Activity destroyed
GlobalScope.launch {
    val user = api.fetchUser()
    updateUi(user) // May crash — Activity already gone
}

// GOOD: Cancelled when ViewModel is cleared
viewModelScope.launch {
    val user = api.fetchUser()
    updateUi(user)
}
```

## Launch Exception Swallowing vs Handling

```kotlin
// BAD: Exception crashes app silently (no stack trace in CrashHandler)
viewModelScope.launch {
    riskyOperation() // Throws → uncaught → app crash
}

// GOOD: Exception caught and handled
viewModelScope.launch {
    runCatching { riskyOperation() }
        .onFailure { e -> _uiState.update { it.copy(error = e.message) } }
}
```

## Async Without Await

```kotlin
// BAD: Deferred result discarded, exception silently lost
scope.async { computeExpensiveResult() }

// GOOD: Always await the result
coroutineScope {
    val result = async { computeExpensiveResult() }
    process(result.await())
}
```

## runBlocking in Production

```kotlin
// BAD: Blocks the calling thread (ANR if main thread)
fun getUser(): User = runBlocking { repo.fetchUser() }

// GOOD: Suspend function, caller decides the scope
suspend fun getUser(): User = repo.fetchUser()
```

## Anti-Pattern Table

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `GlobalScope.launch` | No cancellation, runs after Activity/ViewModel destroyed | `viewModelScope.launch` or `lifecycleScope.launch` |
| `CoroutineScope(Job())` as local variable | No one cancels it, memory/coroutine leak | Bind to class property, cancel in `onCleared`/`onDestroy` |
| `launch {}` without exception handling | Uncaught exception crashes app | `runCatching` inside launch, or `CoroutineExceptionHandler` |
| `async {}` without `await()` | Exception silently lost, result wasted | Always `await()`, or use `launch` if result not needed |
| `withContext(Dispatchers.Main)` containing I/O | ANR — I/O on main thread | `withContext(Dispatchers.IO)` for I/O operations |
| `delay()` polling loop | Wastes resources, ignores lifecycle | `Flow` + `repeatOnLifecycle` for reactive updates |

## Advanced Topics

**supervisorScope vs coroutineScope**
- `coroutineScope`: one child fails → all siblings cancelled. Use for all-or-nothing operations.
- `supervisorScope`: one child fails → siblings continue. Use when children are independent (e.g., parallel API calls where partial results are acceptable).

**NonCancellable**

```kotlin
// Use for cleanup that MUST complete even during cancellation
withContext(NonCancellable) {
    db.saveProgress(currentState) // Must not be skipped
}
```

**Structured Concurrency Principles**
- Parent coroutine waits for all children to complete.
- Cancellation propagates downward (parent cancelled → all children cancelled).
- Exceptions propagate upward (child fails → parent notified).
- A coroutine's lifetime never exceeds its scope's lifetime.

## Rules

1. NEVER use `GlobalScope` — bind to `viewModelScope`, `lifecycleScope`, or custom scope with cancellation.
2. `launch` exceptions don't propagate to callers — must handle via `runCatching`, `try/catch`, or `CoroutineExceptionHandler`.
3. `async` Deferred must be awaited — otherwise exceptions silently lost.
4. `runBlocking` only in `main()` and tests — forbidden in production code.
5. Match Dispatcher to work type: `IO` for blocking I/O, `Default` for CPU-intensive, `Main` for UI updates only.
6. Use `supervisorScope` to isolate child coroutine failures when children are independent.

## Checklist

- [ ] No `GlobalScope` usage
- [ ] All `launch` blocks have exception handling
- [ ] All `async` Deferred values are awaited
- [ ] No `runBlocking` in production code
- [ ] Dispatcher matches work type (IO/Default/Main)
- [ ] CoroutineScope bound to lifecycle or has cancellation mechanism
- [ ] Child failures isolated with `supervisorScope` where appropriate
