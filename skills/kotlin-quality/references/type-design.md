# Type Design

## Exhaustive when on Sealed Types

```kotlin
// BAD: else swallows new sealed subtypes — compiler won't warn
sealed interface UiState {
    data object Loading : UiState
    data class Success(val data: Data) : UiState
    data class Error(val message: String) : UiState
}

when (state) {
    is UiState.Loading -> showLoading()
    else -> {} // If new subtype added, silently ignored
}

// GOOD: Exhaustive — compiler error if new subtype added
when (state) {
    is UiState.Loading -> showLoading()
    is UiState.Success -> showData(state.data)
    is UiState.Error -> showError(state.message)
}
```

## Primitive Parameters vs value class

```kotlin
// BAD: Easy to swap from/to — both are String
fun transfer(from: String, to: String, amount: Long)
transfer("acc-2", "acc-1", 1000) // Swapped! No compiler error

// GOOD: Compiler catches swapped parameters
@JvmInline value class AccountId(val value: String)
@JvmInline value class Amount(val cents: Long)
fun transfer(from: AccountId, to: AccountId, amount: Amount)
```

## Mutable vs Immutable data class

```kotlin
// BAD: var fields — hashCode changes, copy() semantics broken
data class User(var name: String, var age: Int)
val user = User("Alice", 30)
val set = setOf(user)
user.name = "Bob" // hashCode changed! set.contains(user) may return false

// GOOD: All val — predictable, safe for collections
data class User(val name: String, val age: Int)
val updated = user.copy(name = "Bob") // New instance
```

## Pair vs Named Type

```kotlin
// BAD: .first and .second have no semantic meaning
fun parse(raw: String): Pair<String, Int> = TODO()
val result = parse(input)
println(result.first)  // What is "first"? Name? ID? Error?

// GOOD: Self-documenting
data class ParseResult(val name: String, val age: Int)
fun parse(raw: String): ParseResult = TODO()
val result = parse(input)
println(result.name)  // Clear
```

## Anti-Pattern Table

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `when` + `else` on sealed type | New subtypes silently ignored | Exhaust all branches, no `else` |
| 3+ same-type parameters | Caller can swap arguments undetected | `value class` wrappers or data class parameter object |
| `data class` with `var` | `hashCode` instability, broken collection behavior | All fields `val`, use `copy()` for changes |
| `Pair<>` / `Triple<>` in API | `.first`/`.second` are meaningless | Named `data class` |
| `typealias X = String` | No compile-time distinction from raw `String` | `@JvmInline value class X(val value: String)` |

## Advanced Topics

**Sealed Interface vs Sealed Class**
- `sealed class`: use when subtypes share state (common properties in base).
- `sealed interface`: use when subtypes only share behavior (no common state), or when a type needs to implement multiple sealed hierarchies.
- Prefer `sealed interface` as default — more flexible, allows multi-inheritance.

**ADT State Machine Modeling**

```kotlin
sealed interface DownloadState {
    data object Idle : DownloadState
    data class Downloading(val progress: Float) : DownloadState
    data class Completed(val file: File) : DownloadState
    data class Failed(val error: Throwable) : DownloadState
}
// Exhaustive when + smart cast = type-safe state handling
```

**Generic Constraints**

```kotlin
// Multiple constraints with where clause
fun <T> sort(list: List<T>) where T : Comparable<T>, T : Serializable {
    list.sorted()
}
```

**value class Limitations**
- Cannot have `init` blocks with side effects.
- Cannot be used with delegation (`by`).
- Cannot participate in class hierarchies (no inheritance).
- May be boxed when used as nullable or generic type argument.

## Rules

1. Sealed `when` expressions must exhaust all subtypes — no `else` fallback.
2. 3+ same-type parameters must be wrapped in `value class` or parameter `data class`.
3. `data class` fields must all be `val` — mutable data classes break collection contracts.
4. Use `@JvmInline value class` over `typealias` for primitive wrappers — compile-time safety, zero runtime cost.
5. No `Pair` / `Triple` in public API — use named `data class`.

## Checklist

- [ ] Sealed `when` exhausts all subtypes (no `else`)
- [ ] No 3+ same-type primitive parameters
- [ ] `data class` fields all `val`
- [ ] No `Pair` / `Triple` in public API
- [ ] No `Any` as parameter or return type
- [ ] Primitive wrappers use `value class` not `typealias`
