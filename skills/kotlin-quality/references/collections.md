# Collections & Functional Patterns

## Side Effects in map vs onEach

```kotlin
// BAD: map should be pure transformation, side effects hidden
val ids = users.map { user ->
    analytics.track(user)  // Side effect in map!
    user.id
}

// GOOD: Separate concerns — onEach for effects, map for transform
val ids = users
    .onEach { user -> analytics.track(user) }
    .map { user -> user.id }
```

## Mutable Collection Exposure

```kotlin
// BAD: External code can add/remove without ViewModel knowledge
class CartViewModel : ViewModel() {
    val items: MutableList<CartItem> = mutableListOf()
}

// GOOD: Internal mutable, external immutable
class CartViewModel : ViewModel() {
    private val _items = mutableListOf<CartItem>()
    val items: List<CartItem> get() = _items.toList()
}
```

## Long Chain Without Sequence

```kotlin
// BAD: Each operator creates intermediate list (3 allocations for 100k items)
val result = hugeList
    .filter { it.isActive }
    .map { it.transform() }
    .filter { it.isValid }
    .take(10)

// GOOD: Lazy evaluation, single pass, stops after 10 results
val result = hugeList.asSequence()
    .filter { it.isActive }
    .map { it.transform() }
    .filter { it.isValid }
    .take(10)
    .toList()
```

## Scope Function Nesting vs Extraction

```kotlin
// BAD: Nested scope functions — what does "it" refer to?
connection.let { conn ->
    conn.also { it.configure() }.run {
        query.let { q ->
            execute(q)
        }
    }
}

// GOOD: Named functions, clear flow
connection.configure()
val result = connection.execute(query)
```

## Anti-Pattern Table

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Side effects in `map {}` | Violates pure function contract, order-dependent bugs | `onEach {}` for side effects, `map {}` for transform only |
| Public `MutableList` / `MutableMap` | External mutation bypasses encapsulation | Private mutable + public `List` / `Map` getter |
| 4+ chained operators on large list | Multiple intermediate allocations | `asSequence()` for lazy evaluation |
| Scope function nesting >1 level | `it` / `this` ambiguity, unreadable | Extract named functions |
| `toMutableList()` → modify → return | Intent unclear, extra allocation | `buildList {}` builder |

## Advanced Topics

**Scope Function Selection Guide**

| Function | Object ref | Return value | Use case |
|----------|-----------|-------------|----------|
| `let` | `it` | Lambda result | Null check + transform: `x?.let { use(it) }` |
| `run` | `this` | Lambda result | Object config + compute result |
| `apply` | `this` | Object itself | Object initialization / configuration |
| `also` | `it` | Object itself | Additional actions (logging, validation) |
| `with` | `this` | Lambda result | Non-extension `run`: `with(config) { ... }` |

**groupBy vs associateBy**
- `groupBy { it.key }` → `Map<K, List<V>>` (one-to-many). Multiple values per key.
- `associateBy { it.key }` → `Map<K, V>` (one-to-one). Last value wins if duplicate keys.

**fold vs reduce**
- `fold(initial) { acc, item -> }` — has initial value, works on empty collections.
- `reduce { acc, item -> }` — first element is initial, throws on empty collection.
- Prefer `fold` for safety unless you've checked `isNotEmpty()`.

**kotlinx.collections.immutable**

```kotlin
// For Compose: ImmutableList triggers skip optimization
val items: ImmutableList<Item> = persistentListOf(item1, item2)
// Compose compiler treats ImmutableList as @Stable — skips recomposition when reference unchanged
```

## Rules

1. No side effects in `map` / `filter` / `flatMap` — use `onEach` or `forEach` for side effects.
2. Public properties expose immutable collections (`List`, `Set`, `Map`) — never `MutableList`.
3. 3+ chained operators on large collections use `asSequence()` for lazy evaluation.
4. Scope function nesting max 1 level — extract named functions beyond that.
5. Prefer `buildList` / `buildMap` / `buildSet` over `toMutableX()` + modify + return.

## Checklist

- [ ] No side effects in `map` / `filter`
- [ ] Public properties expose immutable collections
- [ ] Large collection chains use `asSequence`
- [ ] Scope function nesting max 1 level
- [ ] Uses `buildList` / `buildMap` over `toMutableX` pattern
