# Responsive Layout & Animation

## Table of Contents
- [Responsive Layout](#responsive-layout)
- [Animation](#animation)

---

## Responsive Layout

### 1. WindowSizeClass for Adaptive Layouts

```kotlin
val windowSizeClass = calculateWindowSizeClass(activity)
when (windowSizeClass.widthSizeClass) {
    WindowWidthSizeClass.Compact -> PhoneLayout()
    WindowWidthSizeClass.Medium -> TabletLayout()
    WindowWidthSizeClass.Expanded -> DesktopLayout()
}
```

### 2. Relative Sizing (No Fixed Widths)

```kotlin
// BAD: breaks on different screens
Box(modifier = Modifier.width(360.dp))

// GOOD: adapts to screen
Box(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp))
```

### 3. BoxWithConstraints

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

## Animation

### 1. animateXAsState for Simple Values

```kotlin
val alpha by animateFloatAsState(
    targetValue = if (isVisible) 1f else 0f,
    animationSpec = tween(300),
    label = "alpha"
)
```

### 2. AnimatedVisibility for Enter/Exit

```kotlin
AnimatedVisibility(
    visible = isVisible,
    enter = fadeIn() + slideInVertically(),
    exit = fadeOut() + slideOutVertically()
) {
    Content()
}
```

### 3. AnimatedContent for Content Transitions

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

### 4. Labels

ALWAYS provide `label` parameter for animations (helps debugging).

### 5. GPU-Accelerated Transforms

```kotlin
Modifier.graphicsLayer {
    scaleX = scale
    scaleY = scale
    alpha = alphaValue
}
```
