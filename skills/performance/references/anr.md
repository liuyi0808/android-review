# ANR Prevention

## Threshold

ANR triggers when main thread is blocked for:
- **5 seconds** for input events
- **10 seconds** for BroadcastReceiver
- Play vitals threshold: **0.47%** ANR rate

## 1. NEVER Perform on Main Thread

- Network requests
- Database queries (even Room, without suspend)
- File I/O
- JSON parsing of large payloads
- Bitmap decoding
- SharedPreferences.commit() (use apply())

## 2. Move Work to Coroutines

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

## 3. SharedPreferences: apply() not commit()

```kotlin
// BAD: blocks main thread
prefs.edit().putString("key", value).commit()

// GOOD: async write
prefs.edit().putString("key", value).apply()
```

## 4. BroadcastReceiver Offloading

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

## Checklist

- [ ] No synchronous I/O on main thread
- [ ] SharedPreferences uses apply(), not commit()
- [ ] BroadcastReceiver offloads work
- [ ] StrictMode enabled in debug to catch violations
- [ ] ANR rate below 0.47% in Play vitals
