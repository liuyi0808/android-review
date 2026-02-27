# Null Safety

## !! vs requireNotNull

```kotlin
// BAD: Crashes with generic KotlinNullPointerException, no context
val name = user!!.name

// GOOD: Crashes with meaningful message, debuggable
val name = requireNotNull(user) { "User must be loaded before accessing name" }.name
```

## ?.let Nesting Hell vs Flattening

```kotlin
// BAD: Deeply nested, hard to follow
fun process(a: A?) {
    a?.let { aVal ->
        aVal.b?.let { bVal ->
            bVal.c?.let { cVal ->
                use(cVal)
            }
        }
    }
}

// GOOD: Early return, flat and readable
fun process(a: A?) {
    val aVal = a ?: return
    val bVal = aVal.b ?: return
    val cVal = bVal.c ?: return
    use(cVal)
}
```

## lateinit Misuse vs lazy

```kotlin
// BAD: Accessed before initialization → UninitializedPropertyAccessException
class Config {
    lateinit var apiUrl: String  // Who initializes this? When?
}

// GOOD: Initialized on first access, thread-safe
class Config {
    val apiUrl: String by lazy { BuildConfig.API_URL }
}
```

## Unsafe as vs as?

```kotlin
// BAD: ClassCastException at runtime
val user = response as User

// GOOD: Safe cast with fallback
val user = response as? User ?: return
```

## Anti-Pattern Table

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `!!` without comment | NPE with no context, hard to debug | `requireNotNull()` with message, or restructure to non-null |
| `lateinit` for optional data | `UninitializedPropertyAccessException` | `by lazy {}` or `var x: T? = null` |
| `?.let { ?.let { } }` nested | Unreadable, logic buried in nesting | Early `?: return`, flat structure |
| `as` unsafe cast | `ClassCastException` at runtime | `as?` + Elvis (`?:`) |
| `catch { null }` silently | Null propagates far from error source, hard to debug | `catch { log(it); throw }` or `Result<T>` |

## Advanced Topics

**?. Chain Max Length**
- Keep `?.` chains to 2 levels max: `user?.address?.city` is OK.
- Beyond 2: extract intermediate variables or use `let`/early return.

**Elvis Throw Pattern**

```kotlin
val user = repo.findById(id)
    ?: throw NotFoundException("User $id not found")
```

Use when absence is truly exceptional. For expected absence, return `null` or `Result`.

**Platform Types (Java Interop)**
- Java methods return `T!` (unknown nullability) in Kotlin.
- ALWAYS declare explicit nullability at the boundary:

```kotlin
// Java: String getName() — could return null
// Kotlin boundary:
val name: String? = javaObject.name  // Explicit nullable
```

**Contract and Smart Cast**

```kotlin
fun validateUser(user: User?) {
    requireNotNull(user) { "User required" }
    // Compiler smart-casts user to User (non-null) after this line
    println(user.name)  // No ?. needed
}
```

`require`, `check`, `requireNotNull`, `checkNotNull` all trigger smart cast.

## Rules

1. `!!` only when compiler can't infer but you can prove non-null — must have comment explaining why.
2. Prefer `requireNotNull()` / `checkNotNull()` over `!!` — provides meaningful error messages.
3. `lateinit` only for DI injection fields and Android lifecycle initialization — all other cases use `by lazy` or nullable type.
4. Flatten null chains: max 2 levels of `?.` — use early `?: return` or `when` for deeper paths.
5. Unsafe `as` only inside `when` type branches — all other cases use `as?` + Elvis.

## Checklist

- [ ] No unjustified `!!` usage (each `!!` has a comment)
- [ ] `lateinit` only for DI and lifecycle
- [ ] No 3+ level `?.` chain nesting
- [ ] Unsafe `as` only in `when` type branches
- [ ] No catch-and-return-null swallowing exceptions
- [ ] Map/List access uses safe methods (`getOrNull` / `getOrElse`)
