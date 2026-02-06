---
name: performance
description: >
  Android application performance optimization guidance. Triggers when discussing or
  reviewing code related to app startup speed, memory management, Compose recomposition,
  layout performance, ANR prevention, battery optimization, image loading, baseline
  profiles, or benchmarking. Also triggers on keywords like "性能", "卡顿", "内存泄漏",
  "ANR", "启动速度", "recomposition", "jank", "OOM", "benchmark", "slow".
model: sonnet
---

# Android Performance Optimization

Identify and resolve performance issues in Android (Kotlin/Compose) applications.

## When to Use

- App startup is slow (cold start > 500ms)
- UI jank or dropped frames
- Memory leaks or OOM crashes
- ANR (Application Not Responding) issues
- Excessive recomposition in Jetpack Compose
- Battery drain complaints
- Play vitals showing poor performance metrics
- Preparing baseline profiles for release

## Performance Audit Process

Evaluate code against ALL categories. Output findings as:

```
[PERF-XXXXX] impact: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <what causes the performance issue>
  Location: <file:line>
  Fix: <concrete optimization>
  Metric: <expected improvement>
```

---

## 1. App Startup Optimization

### Three Startup Types

| Type | Definition | Target |
|------|-----------|--------|
| Cold | Process not running, app launched from scratch | < 500ms |
| Warm | Process alive, Activity recreated | < 300ms |
| Hot | Activity in memory, brought to foreground | < 100ms |

### Rules

1. NEVER do heavy work in `Application.onCreate()`:
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

2. Use `App Startup` library for lazy initialization:
   ```kotlin
   class AnalyticsInitializer : Initializer<Analytics> {
       override fun create(context: Context): Analytics {
           return Analytics.init(context)
       }
       override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
   }
   ```

3. Avoid splash screen blocking — use `SplashScreen` API:
   ```kotlin
   installSplashScreen().apply {
       setKeepOnScreenCondition { isLoading }
   }
   ```

4. Measure startup time:
   ```kotlin
   // In debug builds
   if (BuildConfig.DEBUG) {
       val startTime = SystemClock.elapsedRealtime()
       // ... after first frame
       reportFullyDrawn()  // Reports to Play vitals
       Log.d(TAG, "Startup: ${SystemClock.elapsedRealtime() - startTime}ms")
   }
   ```

### Checklist
- [ ] No synchronous network calls in Application/Activity.onCreate
- [ ] SDK initialization deferred or lazy
- [ ] Content provider initialization reviewed (auto-init SDKs)
- [ ] `reportFullyDrawn()` called after meaningful content displayed
- [ ] Startup trace profiled with Android Studio Profiler

---

## 2. Compose Recomposition

### Rules

1. Use `Stable` and `Immutable` types to prevent unnecessary recomposition:
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

2. Extract lambdas to prevent recomposition:
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

3. Use `key()` for lists to enable efficient diffing:
   ```kotlin
   LazyColumn {
       items(users, key = { it.id }) { user ->
           UserItem(user = user)
       }
   }
   ```

4. Defer reads to narrow recomposition scope:
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

5. Use `derivedStateOf` for computed values:
   ```kotlin
   val showButton by remember {
       derivedStateOf { listState.firstVisibleItemIndex > 0 }
   }
   ```

6. Enable Compose compiler metrics for CI:
   ```kotlin
   // build.gradle.kts
   composeCompiler {
       reportsDestination = layout.buildDirectory.dir("compose_compiler")
       metricsDestination = layout.buildDirectory.dir("compose_compiler")
   }
   ```

### Checklist
- [ ] No unstable parameters in frequently recomposed functions
- [ ] LazyColumn/LazyRow use `key` parameter
- [ ] State reads deferred to layout/draw phase where possible
- [ ] No allocations inside Composable functions (use remember)
- [ ] Compose compiler metrics reviewed (no unexpected restartable groups)

---

## 3. Memory Management

### Rules

1. NEVER hold Activity/Context references in long-lived objects:
   ```kotlin
   // BAD: leaks Activity
   class DataManager(val context: Context) // holds Activity context

   // GOOD: use Application context for long-lived objects
   class DataManager(val context: Context) {
       private val _appContext: Context = context.applicationContext
   }
   ```

2. Cancel coroutines when scope is destroyed:
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

3. Use `WeakReference` for callbacks that may outlive the holder:
   ```kotlin
   class EventBus {
       private val _listeners: MutableList<WeakReference<Listener>> = mutableListOf()
   }
   ```

4. Avoid creating objects in tight loops:
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

5. Use `object` pool for frequently created/destroyed objects.

6. Monitor with LeakCanary in debug builds:
   ```kotlin
   debugImplementation("com.squareup.leakcanary:leakcanary-android:2.14")
   ```

### Checklist
- [ ] No Activity/Fragment context in ViewModel or Repository
- [ ] Coroutines cancelled on scope destruction
- [ ] No static references to Activity/View
- [ ] LeakCanary integrated in debug builds
- [ ] Large bitmaps properly sampled and recycled
- [ ] No unbounded caches

---

## 4. ANR Prevention

### Threshold

ANR triggers when main thread is blocked for:
- **5 seconds** for input events
- **10 seconds** for BroadcastReceiver
- Play vitals threshold: **0.47%** ANR rate

### Rules

1. NEVER perform these on main thread:
   - Network requests
   - Database queries (even Room, without suspend)
   - File I/O
   - JSON parsing of large payloads
   - Bitmap decoding
   - SharedPreferences.commit() (use apply())

2. Move work to coroutines with appropriate dispatcher:
   ```kotlin
   // IO operations
   withContext(Dispatchers.IO) {
       val data = database.query()
       val file = File("path").readText()
   }

   // CPU-intensive work
   withContext(Dispatchers.Default) {
       val result = heavyComputation()
   }
   ```

3. Use `apply()` not `commit()` for SharedPreferences:
   ```kotlin
   // BAD: blocks main thread
   prefs.edit().putString("key", value).commit()

   // GOOD: async write
   prefs.edit().putString("key", value).apply()
   ```

4. BroadcastReceiver must finish within 10 seconds:
   ```kotlin
   class MyReceiver : BroadcastReceiver() {
       override fun onReceive(context: Context, intent: Intent) {
           // Start a coroutine worker for long tasks
           val pendingResult = goAsync()
           CoroutineScope(Dispatchers.IO).launch {
               try {
                   doLongWork()
               } finally {
                   pendingResult.finish()
               }
           }
       }
   }
   ```

### Checklist
- [ ] No synchronous I/O on main thread
- [ ] SharedPreferences uses apply(), not commit()
- [ ] BroadcastReceiver offloads work
- [ ] StrictMode enabled in debug to catch violations
- [ ] ANR rate below 0.47% in Play vitals

---

## 5. Lazy Loading & Pagination

### Rules

1. Use Paging 3 for large data sets:
   ```kotlin
   val pager = Pager(
       config = PagingConfig(
           pageSize = 20,
           prefetchDistance = 5,
           enablePlaceholders = false
       ),
       pagingSourceFactory = { MyPagingSource(api) }
   )
   val flow: Flow<PagingData<Item>> = pager.flow.cachedIn(viewModelScope)
   ```

2. Use `LazyColumn`/`LazyRow` for lists (NEVER `Column` + `forEach` for large lists):
   ```kotlin
   // BAD: composes ALL items
   Column {
       items.forEach { item -> ItemRow(item) }
   }

   // GOOD: only composes visible items
   LazyColumn {
       items(items, key = { it.id }) { item -> ItemRow(item) }
   }
   ```

3. Use Coil/Glide with proper caching for images:
   ```kotlin
   AsyncImage(
       model = ImageRequest.Builder(LocalContext.current)
           .data(url)
           .crossfade(true)
           .size(Size.ORIGINAL)  // or specific size
           .build(),
       contentDescription = null
   )
   ```

---

## 6. Baseline Profiles

### Purpose

Pre-compile hot code paths for 30-40% faster startup and smoother scrolling.

### Setup

```kotlin
// build.gradle.kts (app module)
dependencies {
    implementation("androidx.profileinstaller:profileinstaller:1.4.1")
    baselineProfile(project(":baselineprofile"))
}

// Create :baselineprofile module
// BaselineProfileGenerator.kt
@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {
    @get:Rule
    val rule = BaselineProfileRule()

    @Test
    fun generateBaselineProfile() {
        rule.collect("com.ai.project1") {
            // Critical user journey
            pressHome()
            startActivityAndWait()
            // Navigate through key screens
            device.findObject(By.text("Login")).click()
            device.waitForIdle()
        }
    }
}
```

### Checklist
- [ ] `profileinstaller` dependency added
- [ ] Baseline profile generator covers critical paths (startup, main list, navigation)
- [ ] Profile generated and included in release build
- [ ] Startup time measured before/after profile

---

## 7. Battery & Network Optimization

### Rules

1. Batch network requests. NEVER make individual calls for each item.

2. Use WorkManager for deferrable background work:
   ```kotlin
   val constraints = Constraints.Builder()
       .setRequiredNetworkType(NetworkType.UNMETERED)
       .setRequiresBatteryNotLow(true)
       .build()
   val workRequest = OneTimeWorkRequestBuilder<SyncWorker>()
       .setConstraints(constraints)
       .build()
   WorkManager.getInstance(context).enqueue(workRequest)
   ```

3. Respect doze mode. Use `setAndAllowWhileIdle()` sparingly.

4. Cache aggressively. Use OkHttp cache + Room for offline support:
   ```kotlin
   val cache = Cache(cacheDir, 10L * 1024 * 1024)  // 10 MB
   val client = OkHttpClient.Builder()
       .cache(cache)
       .build()
   ```

### Checklist
- [ ] No wake locks held longer than necessary
- [ ] Background work uses WorkManager (not AlarmManager)
- [ ] Network requests batched and cached
- [ ] Location updates use appropriate interval and accuracy
- [ ] No continuous sensor polling

---

## Audit Output Format

```markdown
## Performance Audit Report

### Summary
- Critical: X | High: X | Medium: X | Low: X

### Findings
#### [CRITICAL] PERF-STARTUP-001: Synchronous SDK init in Application.onCreate
- File: App.kt:15
- Impact: +400ms cold start time
- Fix: Defer to background thread or lazy init

### Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Cold start | 1200ms | <500ms | FAIL |
| ANR rate | 0.8% | <0.47% | FAIL |
| Crash rate | 0.5% | <1.09% | PASS |
| Memory peak | 180MB | <150MB | WARNING |
```
