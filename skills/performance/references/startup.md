# App Startup Optimization

## Three Startup Types

| Type | Definition | Target |
|------|-----------|--------|
| Cold | Process not running, app launched from scratch | < 500ms |
| Warm | Process alive, Activity recreated | < 300ms |
| Hot | Activity in memory, brought to foreground | < 100ms |

## 1. NEVER Do Heavy Work in Application.onCreate

```kotlin
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        // BAD: synchronous SDK initialization
        // AnalyticsSDK.init(this)  // 200ms
        // CrashReporter.init(this) // 150ms

        // GOOD: defer non-critical initialization
        ProcessLifecycleOwner.get().lifecycle.addObserver(
            object : DefaultLifecycleObserver {
                override fun onStart(owner: LifecycleOwner) {
                    // Initialize when app becomes visible
                    AnalyticsSDK.init(this@App)
                }
            }
        )
    }
}
```

## 2. App Startup Library for Lazy Initialization

```kotlin
class AnalyticsInitializer : Initializer<Analytics> {
    override fun create(context: Context): Analytics {
        return Analytics.init(context)
    }
    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
```

## 3. SplashScreen API

```kotlin
installSplashScreen().apply {
    setKeepOnScreenCondition { isLoading }
}
```

## 4. Measure Startup Time

```kotlin
// In debug builds
if (BuildConfig.DEBUG) {
    val startTime = SystemClock.elapsedRealtime()
    // ... after first frame
    reportFullyDrawn()  // Reports to Play vitals
    Log.d(TAG, "Startup: ${SystemClock.elapsedRealtime() - startTime}ms")
}
```

## Checklist

- [ ] No synchronous network calls in Application/Activity.onCreate
- [ ] SDK initialization deferred or lazy
- [ ] Content provider initialization reviewed (auto-init SDKs)
- [ ] `reportFullyDrawn()` called after meaningful content displayed
- [ ] Startup trace profiled with Android Studio Profiler
