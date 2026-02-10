# State Management & Side Effects

## Table of Contents
- [State Management](#state-management)
- [Side Effects](#side-effects)

---

## State Management

### 1. State Hoisting (Stateless Composables)

```kotlin
// BAD: stateful component (hard to test, hard to reuse)
@Composable
fun SearchBar() {
    var query by remember { mutableStateOf("") }
    TextField(value = query, onValueChange = { query = it })
}

// GOOD: stateless component with state hoisting
@Composable
fun SearchBar(
    query: String,
    onQueryChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    TextField(
        value = query,
        onValueChange = onQueryChange,
        modifier = modifier
    )
}
```

### 2. rememberSaveable for Configuration Changes

```kotlin
var text by rememberSaveable { mutableStateOf("") }
```

### 3. Complex State in ViewModel

```kotlin
class SearchViewModel : ViewModel() {
    private val _uiState: MutableStateFlow<SearchUiState> =
        MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()
}

// In Composable — See architecture skill for ViewModel implementation patterns
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```

### 4. collectAsStateWithLifecycle (NOT collectAsState)

```kotlin
// BAD: continues collecting when app is in background
val state by flow.collectAsState()

// GOOD: lifecycle-aware, stops in background
val state by flow.collectAsStateWithLifecycle()
```

### 5. Sealed Interface for UI State

```kotlin
sealed interface SearchUiState {
    data object Loading : SearchUiState
    data class Success(val results: ImmutableList<Result>) : SearchUiState
    data class Error(val message: String) : SearchUiState
}
```

---

## Side Effects

### 1. LaunchedEffect

```kotlin
// Runs when key changes, cancelled on leave/key change
LaunchedEffect(userId) {
    viewModel.loadUser(userId)
}
```

### 2. DisposableEffect

```kotlin
DisposableEffect(lifecycleOwner) {
    val observer = LifecycleEventObserver { _, event -> ... }
    lifecycleOwner.lifecycle.addObserver(observer)
    onDispose {
        lifecycleOwner.lifecycle.removeObserver(observer)
    }
}
```

### 3. SideEffect

```kotlin
SideEffect {
    analytics.logScreenView(screenName)
}
```

### 4. rememberCoroutineScope

```kotlin
val scope = rememberCoroutineScope()
Button(onClick = {
    scope.launch { scaffoldState.snackbarHostState.showSnackbar("Done") }
})
```

### 5. NEVER Launch Coroutines in Composable Body

```kotlin
// BAD: launches on every recomposition
@Composable
fun Bad() {
    CoroutineScope(Dispatchers.IO).launch { loadData() }
}

// GOOD: controlled by key
@Composable
fun Good() {
    LaunchedEffect(Unit) { loadData() }
}
```
