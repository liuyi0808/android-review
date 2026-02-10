# Memory Management

## 1. NEVER Hold Activity/Context in Long-Lived Objects

```kotlin
// BAD: leaks Activity
class DataManager(val context: Context) // holds Activity context

// GOOD: use Application context for long-lived objects
class DataManager(val context: Context) {
    private val _appContext: Context = context.applicationContext
}
```

## 2. Cancel Coroutines on Scope Destruction

```kotlin
// ViewModel: viewModelScope auto-cancels
class MyViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch { ... }  // auto-cancelled
    }
}

// Composable: use LaunchedEffect (auto-cancels)
LaunchedEffect(key) {
    // auto-cancelled when key changes or composable leaves
}
```

## 3. WeakReference for Callbacks

```kotlin
class EventBus {
    private val _listeners: MutableList<WeakReference<Listener>> = mutableListOf()
}
```

## 4. Avoid Object Allocation in Loops

```kotlin
// BAD: allocates on every iteration
for (i in items.indices) {
    val rect = Rect()  // allocation in loop
    canvas.getClipBounds(rect)
}

// GOOD: reuse object
val rect = Rect()
for (i in items.indices) {
    canvas.getClipBounds(rect)
}
```

## 5. Object Pools

Use `object` pool for frequently created/destroyed objects.

## 6. LeakCanary

```kotlin
debugImplementation("com.squareup.leakcanary:leakcanary-android:2.14")
```

## Checklist

- [ ] No Activity/Fragment context in ViewModel or Repository
- [ ] Coroutines cancelled on scope destruction
- [ ] No static references to Activity/View
- [ ] LeakCanary integrated in debug builds
- [ ] Large bitmaps properly sampled and recycled
- [ ] No unbounded caches
