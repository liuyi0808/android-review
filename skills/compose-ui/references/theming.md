# Theming & Material 3

## 1. Material 3 Tokens (No Hardcoded Colors)

```kotlin
// BAD
Text(color = Color(0xFF1976D2))

// GOOD
Text(color = MaterialTheme.colorScheme.primary)
```

## 2. Dynamic Colors (Android 12+)

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

## 3. Custom Theme Extensions

```kotlin
@Immutable
data class ExtendedColors(
    val success: Color,
    val warning: Color,
    val info: Color
)
val LocalExtendedColors = staticCompositionLocalOf { ExtendedColors(...) }
```

## 4. Typography

Use `MaterialTheme.typography` for text styles, NEVER hardcoded sizes.
