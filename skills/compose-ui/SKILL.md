---
name: compose-ui
description: >
  Jetpack Compose UI best practices and patterns. Triggers when writing or reviewing
  Compose code involving state management, side effects, navigation, theming, accessibility,
  animation, custom layouts, or responsive design. Also triggers on keywords like "Compose",
  "Composable", "remember", "LaunchedEffect", "recomposition", "Material3", "state",
  "无障碍", "主题", "动画".
model: sonnet
---

# Compose UI Best Practices

Provide guidance and review for Jetpack Compose UI code following Material 3
design patterns and modern Android conventions.

## When to Use

- Writing new Compose UI code
- Reviewing existing Compose components
- Implementing state management in Compose
- Adding side effects (API calls, navigation events)
- Building responsive layouts
- Implementing accessibility
- Creating animations
- Setting up theming and design system

## Review Process

Evaluate Compose code against ALL categories. Output findings as:

```
[COMPOSE-XXXXX] severity: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <what is wrong or can be improved>
  Location: <file:line>
  Fix: <concrete code fix>
```

---

## 1. State Management

### Rules

1. State ownership: state hoisted to the lowest common ancestor.
   Compose functions should be **stateless** where possible:
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

2. Use `rememberSaveable` for state that survives configuration changes:
   ```kotlin
   var text by rememberSaveable { mutableStateOf("") }
   ```

3. Complex state belongs in ViewModel, exposed as `StateFlow`:
   ```kotlin
   class SearchViewModel : ViewModel() {
       private val _uiState: MutableStateFlow<SearchUiState> =
           MutableStateFlow(SearchUiState())
       val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()
   }

   // In Composable
   val uiState by viewModel.uiState.collectAsStateWithLifecycle()
   ```

4. ALWAYS use `collectAsStateWithLifecycle()` (NOT `collectAsState()`):
   ```kotlin
   // BAD: continues collecting when app is in background
   val state by flow.collectAsState()

   // GOOD: lifecycle-aware, stops in background
   val state by flow.collectAsStateWithLifecycle()
   ```

5. Use sealed interface for UI state:
   ```kotlin
   sealed interface SearchUiState {
       data object Loading : SearchUiState
       data class Success(val results: ImmutableList<Result>) : SearchUiState
       data class Error(val message: String) : SearchUiState
   }
   ```

### Checklist
- [ ] UI state exposed as StateFlow from ViewModel
- [ ] collectAsStateWithLifecycle used (not collectAsState)
- [ ] Composable parameters are stable/immutable
- [ ] State hoisted to appropriate level
- [ ] rememberSaveable for user input that survives rotation
- [ ] Sealed interface for screen state

---

## 2. Side Effects

### Rules

1. `LaunchedEffect` for coroutine-based side effects:
   ```kotlin
   // Runs when key changes, cancelled on leave/key change
   LaunchedEffect(userId) {
       viewModel.loadUser(userId)
   }
   ```

2. `DisposableEffect` for cleanup-requiring side effects:
   ```kotlin
   DisposableEffect(lifecycleOwner) {
       val observer = LifecycleEventObserver { _, event -> ... }
       lifecycleOwner.lifecycle.addObserver(observer)
       onDispose {
           lifecycleOwner.lifecycle.removeObserver(observer)
       }
   }
   ```

3. `SideEffect` for non-suspend side effects that run on every successful recomposition:
   ```kotlin
   SideEffect {
       analytics.logScreenView(screenName)
   }
   ```

4. `rememberCoroutineScope` for event-triggered coroutines:
   ```kotlin
   val scope = rememberCoroutineScope()
   Button(onClick = {
       scope.launch { scaffoldState.snackbarHostState.showSnackbar("Done") }
   })
   ```

5. NEVER launch coroutines directly in Composable body:
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

### Checklist
- [ ] No coroutine launches outside side effect handlers
- [ ] LaunchedEffect keys match the data they depend on
- [ ] DisposableEffect used when cleanup is needed
- [ ] rememberCoroutineScope for user-triggered actions

---

## 3. Navigation

### Rules

1. Use type-safe navigation (Navigation Compose 2.8+):
   ```kotlin
   @Serializable data object Login
   @Serializable data object Home
   @Serializable data class Profile(val userId: String)

   NavHost(navController = navController, startDestination = Login) {
       composable<Login> { LoginScreen(onLogin = { navController.navigate(Home) }) }
       composable<Home> { HomeScreen() }
       composable<Profile> { backStackEntry ->
           val profile: Profile = backStackEntry.toRoute<Profile>()
           ProfileScreen(userId = profile.userId)
       }
   }
   ```

2. Navigate with `popUpTo` to avoid back stack buildup:
   ```kotlin
   navController.navigate(Home) {
       popUpTo(Login) { inclusive = true }  // remove login from back stack
   }
   ```

3. NEVER pass complex objects as navigation arguments. Pass IDs, fetch in destination.

4. One-time navigation events via Channel/SharedFlow (NOT LiveData/StateFlow):
   ```kotlin
   // ViewModel
   private val _navigationEvent: Channel<NavigationEvent> = Channel()
   val navigationEvent: Flow<NavigationEvent> = _navigationEvent.receiveAsFlow()

   // Composable
   LaunchedEffect(Unit) {
       viewModel.navigationEvent.collect { event ->
           when (event) {
               is NavigationEvent.GoToProfile -> navController.navigate(Profile(event.userId))
           }
       }
   }
   ```

### Checklist
- [ ] Type-safe navigation routes (Serializable objects)
- [ ] No complex objects passed as arguments
- [ ] Back stack managed properly (popUpTo where needed)
- [ ] One-time events use Channel, not StateFlow

---

## 4. Theming & Material 3

### Rules

1. Use Material 3 tokens, NEVER hardcoded colors:
   ```kotlin
   // BAD
   Text(color = Color(0xFF1976D2))

   // GOOD
   Text(color = MaterialTheme.colorScheme.primary)
   ```

2. Support dynamic colors (Android 12+):
   ```kotlin
   @Composable
   fun AppTheme(content: @Composable () -> Unit) {
       val colorScheme = when {
           Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
               if (isSystemInDarkTheme()) dynamicDarkColorScheme(LocalContext.current)
               else dynamicLightColorScheme(LocalContext.current)
           }
           isSystemInDarkTheme() -> DarkColorScheme
           else -> LightColorScheme
       }
       MaterialTheme(colorScheme = colorScheme, content = content)
   }
   ```

3. Define custom theme extensions for app-specific tokens:
   ```kotlin
   @Immutable
   data class ExtendedColors(
       val success: Color,
       val warning: Color,
       val info: Color
   )
   val LocalExtendedColors = staticCompositionLocalOf { ExtendedColors(...) }
   ```

4. Use `MaterialTheme.typography` for text styles, NEVER hardcoded sizes.

### Checklist
- [ ] No hardcoded colors (use colorScheme tokens)
- [ ] No hardcoded text sizes (use typography tokens)
- [ ] Dark theme supported
- [ ] Dynamic colors supported (Android 12+)
- [ ] Custom tokens use CompositionLocal

---

## 5. Accessibility

### Rules

1. ALL interactive elements MUST have content descriptions:
   ```kotlin
   // BAD
   IconButton(onClick = onClose) {
       Icon(Icons.Default.Close, contentDescription = null)  // inaccessible
   }

   // GOOD
   IconButton(onClick = onClose) {
       Icon(Icons.Default.Close, contentDescription = "Close")
   }
   ```

2. Decorative elements use `null` contentDescription:
   ```kotlin
   Image(painter = backgroundImage, contentDescription = null)  // decorative
   ```

3. Minimum touch target: 48dp × 48dp:
   ```kotlin
   Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
   ```

4. Merge semantics for grouped content:
   ```kotlin
   Row(modifier = Modifier.semantics(mergeDescendants = true) {}) {
       Icon(Icons.Default.Star, contentDescription = null)
       Text("4.5 stars")
       // Screen reader announces: "4.5 stars"
   }
   ```

5. Use `Modifier.clearAndSetSemantics` for custom announcements:
   ```kotlin
   Row(modifier = Modifier.clearAndSetSemantics {
       contentDescription = "Rating: 4.5 out of 5 stars"
   }) { ... }
   ```

6. State descriptions for toggles:
   ```kotlin
   Switch(
       checked = isEnabled,
       onCheckedChange = onToggle,
       modifier = Modifier.semantics {
           stateDescription = if (isEnabled) "Enabled" else "Disabled"
       }
   )
   ```

### Checklist
- [ ] All clickable elements have contentDescription
- [ ] Touch targets ≥ 48dp
- [ ] Semantics merged for logical groups
- [ ] Screen reader tested (TalkBack)
- [ ] Sufficient color contrast (4.5:1 for text)

---

## 6. Responsive Layout

### Rules

1. Use `WindowSizeClass` for adaptive layouts:
   ```kotlin
   val windowSizeClass = calculateWindowSizeClass(activity)
   when (windowSizeClass.widthSizeClass) {
       WindowWidthSizeClass.Compact -> PhoneLayout()
       WindowWidthSizeClass.Medium -> TabletLayout()
       WindowWidthSizeClass.Expanded -> DesktopLayout()
   }
   ```

2. Use `Modifier.fillMaxWidth()` with constraints, not fixed widths:
   ```kotlin
   // BAD: breaks on different screens
   Box(modifier = Modifier.width(360.dp))

   // GOOD: adapts to screen
   Box(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp))
   ```

3. Use `BoxWithConstraints` for constraint-dependent layouts:
   ```kotlin
   BoxWithConstraints {
       if (maxWidth > 600.dp) {
           TwoColumnLayout()
       } else {
           SingleColumnLayout()
       }
   }
   ```

---

## 7. Animation

### Rules

1. Use `animateXAsState` for simple value animations:
   ```kotlin
   val alpha by animateFloatAsState(
       targetValue = if (isVisible) 1f else 0f,
       animationSpec = tween(300),
       label = "alpha"
   )
   ```

2. Use `AnimatedVisibility` for enter/exit:
   ```kotlin
   AnimatedVisibility(
       visible = isVisible,
       enter = fadeIn() + slideInVertically(),
       exit = fadeOut() + slideOutVertically()
   ) {
       Content()
   }
   ```

3. Use `AnimatedContent` for content transitions:
   ```kotlin
   AnimatedContent(
       targetState = uiState,
       transitionSpec = { fadeIn() togetherWith fadeOut() },
       label = "content"
   ) { state ->
       when (state) {
           is Loading -> LoadingIndicator()
           is Success -> ContentList(state.data)
       }
   }
   ```

4. ALWAYS provide `label` parameter for animations (helps debugging).

5. Use `Modifier.graphicsLayer` for GPU-accelerated transforms:
   ```kotlin
   Modifier.graphicsLayer {
       scaleX = scale
       scaleY = scale
       alpha = alphaValue
   }
   ```

### Checklist
- [ ] Animations use appropriate API (animateXAsState, AnimatedVisibility, etc.)
- [ ] All animations have label parameter
- [ ] No infinite animations without user control
- [ ] Animations respect `prefers-reduced-motion` accessibility setting
- [ ] Complex animations use `Transition` for coordination

---

## Component Design Principles

### Composable Function Signature Convention

```kotlin
@Composable
fun MyComponent(
    // 1. Required data parameters
    title: String,
    items: ImmutableList<Item>,
    // 2. Optional data parameters with defaults
    subtitle: String = "",
    // 3. Event callbacks
    onClick: () -> Unit,
    onItemSelected: (Item) -> Unit,
    // 4. Modifier (always last with default)
    modifier: Modifier = Modifier
) {
    // Implementation
}
```

### Preview

```kotlin
@Preview(showBackground = true)
@Preview(showBackground = true, uiMode = UI_MODE_NIGHT_YES)
@Preview(showBackground = true, device = Devices.TABLET)
@Composable
private fun MyComponentPreview() {
    AppTheme {
        MyComponent(
            title = "Preview Title",
            items = persistentListOf(Item("1", "Sample")),
            onClick = {},
            onItemSelected = {}
        )
    }
}
```

### Checklist
- [ ] Modifier is last parameter with default
- [ ] Previews for light/dark/tablet
- [ ] Stateless where possible (state hoisted)
- [ ] Parameters are stable types
