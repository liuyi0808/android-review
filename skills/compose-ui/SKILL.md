---
name: compose-ui
description: >-
  Jetpack Compose UI best practices and patterns for Material 3. Use when: writing
  or reviewing Compose UI code, implementing state hoisting, using side effects
  (LaunchedEffect, DisposableEffect), setting up type-safe navigation, building
  responsive layouts with WindowSizeClass, implementing accessibility (content
  descriptions, touch targets, semantics), creating animations (AnimatedVisibility,
  animateXAsState), or designing reusable composable components.
---

# Compose UI Best Practices

Provide guidance and review for Jetpack Compose UI code following Material 3
design patterns and modern Android conventions.

## Review Process

Evaluate Compose code against ALL categories. Output findings as:

```
[COMPOSE-XXXXX] severity: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <what is wrong or can be improved>
  Location: <file:line>
  Fix: <concrete code fix>
```

---

## Reference Guide — Load on Demand

Each reference file contains full code examples and patterns. **Read the relevant file when reviewing that area.**

| # | Reference File | Content | When to Load |
|---|---------------|---------|-------------|
| 1 | [references/state-and-effects.md](references/state-and-effects.md) | State hoisting, rememberSaveable, collectAsStateWithLifecycle, LaunchedEffect, DisposableEffect, SideEffect | Reviewing state management or side effects |
| 2 | [references/navigation.md](references/navigation.md) | Type-safe navigation, back stack, navigation events | Reviewing navigation setup |
| 3 | [references/theming.md](references/theming.md) | Material 3 tokens, dynamic colors, custom extensions | Reviewing theme or color usage |
| 4 | [references/accessibility.md](references/accessibility.md) | Content descriptions, touch targets, semantics merging | Reviewing accessibility compliance |
| 5 | [references/layout-and-animation.md](references/layout-and-animation.md) | WindowSizeClass, responsive layout, AnimatedVisibility, animateXAsState | Reviewing layout or animation code |

---

## Rules Summary

### State Management
1. State ownership: state hoisted to the lowest common ancestor.
2. Use `rememberSaveable` for state that survives configuration changes.
3. Complex state belongs in ViewModel, exposed as `StateFlow`. See architecture skill for ViewModel implementation patterns.
4. ALWAYS use `collectAsStateWithLifecycle()` (NOT `collectAsState()`).
5. Use sealed interface for UI state.

### Side Effects
1. `LaunchedEffect` for coroutine-based side effects.
2. `DisposableEffect` for cleanup-requiring side effects.
3. `SideEffect` for non-suspend side effects on every successful recomposition.
4. `rememberCoroutineScope` for event-triggered coroutines.
5. NEVER launch coroutines directly in Composable body.

### Navigation
1. Use type-safe navigation (Navigation Compose 2.8+).
2. Navigate with `popUpTo` to avoid back stack buildup.
3. NEVER pass complex objects as navigation arguments. Pass IDs, fetch in destination.
4. One-time navigation events via Channel/SharedFlow. See architecture skill for event channel pattern.

### Theming & Material 3
1. Use Material 3 tokens, NEVER hardcoded colors.
2. Support dynamic colors (Android 12+).
3. Define custom theme extensions via `CompositionLocal`.
4. Use `MaterialTheme.typography` for text styles, NEVER hardcoded sizes.

### Accessibility
1. ALL interactive elements MUST have content descriptions.
2. Decorative elements use `null` contentDescription.
3. Minimum touch target: 48dp x 48dp.
4. Merge semantics for grouped content.
5. Use `Modifier.clearAndSetSemantics` for custom announcements.
6. State descriptions for toggles.

### Responsive Layout
1. Use `WindowSizeClass` for adaptive layouts.
2. Use `Modifier.fillMaxWidth()` with constraints, not fixed widths.
3. Use `BoxWithConstraints` for constraint-dependent layouts.

### Animation
1. Use `animateXAsState` for simple value animations.
2. Use `AnimatedVisibility` for enter/exit.
3. Use `AnimatedContent` for content transitions.
4. ALWAYS provide `label` parameter for animations.
5. Use `Modifier.graphicsLayer` for GPU-accelerated transforms.

---

## Checklists

### State Management
- [ ] UI state exposed as StateFlow from ViewModel
- [ ] collectAsStateWithLifecycle used (not collectAsState)
- [ ] Composable parameters are stable/immutable
- [ ] State hoisted to appropriate level
- [ ] rememberSaveable for user input that survives rotation
- [ ] Sealed interface for screen state

### Side Effects
- [ ] No coroutine launches outside side effect handlers
- [ ] LaunchedEffect keys match the data they depend on
- [ ] DisposableEffect used when cleanup is needed
- [ ] rememberCoroutineScope for user-triggered actions

### Navigation
- [ ] Type-safe navigation routes (Serializable objects)
- [ ] No complex objects passed as arguments
- [ ] Back stack managed properly (popUpTo where needed)
- [ ] One-time events use Channel, not StateFlow

### Theming & Material 3
- [ ] No hardcoded colors (use colorScheme tokens)
- [ ] No hardcoded text sizes (use typography tokens)
- [ ] Dark theme supported
- [ ] Dynamic colors supported (Android 12+)
- [ ] Custom tokens use CompositionLocal

### Accessibility
- [ ] All clickable elements have contentDescription
- [ ] Touch targets >= 48dp
- [ ] Semantics merged for logical groups
- [ ] Screen reader tested (TalkBack)
- [ ] Sufficient color contrast (4.5:1 for text)

### Animation
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

### Component Checklist
- [ ] Modifier is last parameter with default
- [ ] Previews for light/dark/tablet
- [ ] Stateless where possible (state hoisted)
- [ ] Parameters are stable types

---

*For ViewModel implementation patterns, see the `architecture` skill. For performance optimization of Compose recomposition, see the `performance` skill.*
