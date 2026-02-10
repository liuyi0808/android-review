# Battery & Network Optimization

## 1. Batch Network Requests

NEVER make individual calls for each item.

## 2. WorkManager for Deferrable Background Work

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

## 3. Doze Mode

Respect doze mode. Use `setAndAllowWhileIdle()` sparingly.

## 4. Cache Aggressively

```kotlin
val cache = Cache(cacheDir, 10L * 1024 * 1024)  // 10 MB
val client = OkHttpClient.Builder()
    .cache(cache)
    .build()
```

## Checklist

- [ ] No wake locks held longer than necessary
- [ ] Background work uses WorkManager (not AlarmManager)
- [ ] Network requests batched and cached
- [ ] Location updates use appropriate interval and accuracy
- [ ] No continuous sensor polling
