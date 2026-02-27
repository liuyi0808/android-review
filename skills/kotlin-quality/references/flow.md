# Flow

## Bare Collect vs repeatOnLifecycle

```kotlin
// BAD: Continues collecting when app is in background, wastes resources
lifecycleScope.launch {
    viewModel.uiState.collect { state ->
        updateUi(state)
    }
}

// GOOD: Stops collecting when lifecycle falls below STARTED
lifecycleScope.launch {
    repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            updateUi(state)
        }
    }
}
```

## catch Position Error

```kotlin
// BAD: catch after collect — never executes (collect suspends indefinitely)
flow
    .collect { process(it) }
    // .catch { } ← unreachable for upstream errors

// GOOD: catch before collect — catches upstream exceptions
flow
    .catch { e -> emit(fallbackValue) }
    .collect { process(it) }
```

## Mutable Flow Exposure

```kotlin
// BAD: External code can modify state directly
class MyViewModel : ViewModel() {
    val uiState = MutableStateFlow(UiState())  // Public mutable!
}

// GOOD: Private mutable, public read-only
class MyViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
}
```

## stateIn vs shareIn Confusion

```kotlin
// BAD: shareIn for UI state — new subscribers miss current value
val uiState = repository.observe()
    .shareIn(viewModelScope, SharingStarted.WhileSubscribed(), replay = 1)

// GOOD: stateIn for UI state — always has current value
val uiState = repository.observe()
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), UiState())
```

## Anti-Pattern Table

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `lifecycleScope.launch { flow.collect }` | Collects in background, wastes resources | `repeatOnLifecycle(STARTED) { flow.collect }` |
| `.catch {}` after `.collect {}` | catch never executes for upstream errors | Move `.catch {}` before `.collect {}` |
| `.flowOn()` after `.collect {}` | flowOn only affects upstream, position is wrong | Move `.flowOn()` before `.collect {}` |
| Public `MutableStateFlow` | External code can bypass ViewModel logic | Private `_state` + public `asStateFlow()` |
| `stateIn(SharingStarted.Eagerly)` | Computes even without subscribers | `SharingStarted.WhileSubscribed(5_000)` |

## Advanced Topics

**conflate vs collectLatest**
- `conflate()`: keeps latest emitted value, drops intermediate. Use when only latest state matters (e.g., search suggestions).
- `collectLatest {}`: cancels previous collection block when new value arrives. Use when collection involves work that should be restarted (e.g., API call on search query change).

**combine vs zip**
- `combine`: emits whenever ANY source emits (latest from each). Use for UI state derived from multiple sources.
- `zip`: emits only when ALL sources have a new value (pairs them 1:1). Use for request-response pairing.

**Cold Flow vs Hot Flow**
- Cold (`flow {}`): code runs only when collected, each collector gets independent execution.
- Hot (`StateFlow`, `SharedFlow`): exists independently of collectors, shares state.
- Convert cold to hot with `stateIn()` or `shareIn()`.

**Testing with Turbine**

```kotlin
@Test
fun `emits loading then success`() = runTest {
    viewModel.uiState.test {
        assertEquals(UiState.Loading, awaitItem())
        assertEquals(UiState.Success(data), awaitItem())
        cancelAndConsumeRemainingEvents()
    }
}
```

## Rules

1. UI collection must use `repeatOnLifecycle` or `collectAsStateWithLifecycle` — never bare `collect` in `lifecycleScope`.
2. `MutableStateFlow` / `MutableSharedFlow` must be `private` — expose as read-only via `asStateFlow()` / `asSharedFlow()`.
3. `catch` only catches upstream exceptions — must precede `collect`.
4. `flowOn` only changes upstream Dispatcher — must precede `collect`.
5. `stateIn` for UI state (has initial value, replays current), `shareIn` for events (no replay or replay=0).

## Checklist

- [ ] UI collect uses `repeatOnLifecycle` or `collectAsStateWithLifecycle`
- [ ] `MutableStateFlow` / `MutableSharedFlow` are private
- [ ] `catch` precedes `collect`
- [ ] `flowOn` precedes `collect`
- [ ] `stateIn` for state, `shareIn` for events
- [ ] No side effects in `flow {}` builder
