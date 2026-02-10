# Accessibility

## 1. Content Descriptions for Interactive Elements

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

## 2. Decorative Elements

```kotlin
Image(painter = backgroundImage, contentDescription = null)  // decorative
```

## 3. Touch Targets (48dp minimum)

```kotlin
Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
```

## 4. Merge Semantics

```kotlin
Row(modifier = Modifier.semantics(mergeDescendants = true) {}) {
    Icon(Icons.Default.Star, contentDescription = null)
    Text("4.5 stars")
    // Screen reader announces: "4.5 stars"
}
```

## 5. Custom Announcements

```kotlin
Row(modifier = Modifier.clearAndSetSemantics {
    contentDescription = "Rating: 4.5 out of 5 stars"
}) { ... }
```

## 6. State Descriptions for Toggles

```kotlin
Switch(
    checked = isEnabled,
    onCheckedChange = onToggle,
    modifier = Modifier.semantics {
        stateDescription = if (isEnabled) "Enabled" else "Disabled"
    }
)
```
