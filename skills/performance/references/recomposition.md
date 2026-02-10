# Compose Recomposition

## 1. Stable and Immutable Types

```kotlin
// BAD: List is unstable, causes recomposition
@Composable
fun UserList(users: List<User>) { ... }

// GOOD: Use ImmutableList (kotlinx.collections.immutable)
@Composable
fun UserList(users: ImmutableList<User>) { ... }

// GOOD: Or annotate
@Immutable
data class UserListState(
    val users: List<User> = emptyList()
)
```

## 2. Extract Lambdas

```kotlin
// BAD: new lambda on every recomposition
@Composable
fun Parent() {
    val viewModel: MyViewModel = viewModel()
    Child(onClick = { viewModel.doSomething() })
}

// GOOD: remember the lambda
@Composable
fun Parent() {
    val viewModel: MyViewModel = viewModel()
    val onClick = remember { { viewModel.doSomething() } }
    Child(onClick = onClick)
}
```

## 3. Use key() for Lists

```kotlin
LazyColumn {
    items(users, key = { it.id }) { user ->
        UserItem(user = user)
    }
}
```

## 4. Defer Reads

```kotlin
// BAD: entire composable recomposes on scroll
@Composable
fun Header(scrollState: ScrollState) {
    val alpha = scrollState.value / 100f  // reads state here
    Box(modifier = Modifier.alpha(alpha))
}

// GOOD: defer read to layout/draw phase
@Composable
fun Header(scrollState: ScrollState) {
    Box(modifier = Modifier.graphicsLayer {
        alpha = scrollState.value / 100f  // read in draw phase
    })
}
```

## 5. derivedStateOf for Computed Values

```kotlin
val showButton by remember {
    derivedStateOf { listState.firstVisibleItemIndex > 0 }
}
```

## 6. Compose Compiler Metrics

```kotlin
// build.gradle.kts
composeCompiler {
    reportsDestination = layout.buildDirectory.dir("compose_compiler")
    metricsDestination = layout.buildDirectory.dir("compose_compiler")
}
```

## Checklist

- [ ] No unstable parameters in frequently recomposed functions
- [ ] LazyColumn/LazyRow use `key` parameter
- [ ] State reads deferred to layout/draw phase where possible
- [ ] No allocations inside Composable functions (use remember)
- [ ] Compose compiler metrics reviewed (no unexpected restartable groups)
