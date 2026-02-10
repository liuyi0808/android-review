# MASVS-STORAGE: Secure Data Storage

Sensitive data (credentials, tokens, PII) must never be stored in plaintext or world-readable locations.

## Bad: Plaintext SharedPreferences

```kotlin
// BAD: Plaintext storage of sensitive data
val prefs = context.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
prefs.edit().putString("auth_token", "eyJhbGciOiJIUzI1NiIs...").apply()
prefs.edit().putString("password", "hunter2").apply()
```

## Good: EncryptedSharedPreferences + Android Keystore

```kotlin
// GOOD: AES-256 encryption backed by Android Keystore
private fun createEncryptedPrefs(context: Context): SharedPreferences {
    val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
    return EncryptedSharedPreferences.create(
        context, "secure_prefs", masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
}
```

## Checklist

- [ ] No plaintext passwords, tokens, or PII in SharedPreferences
- [ ] EncryptedSharedPreferences for all sensitive key-value data
- [ ] EncryptedFile for sensitive file storage; no sensitive data on external storage
- [ ] No sensitive data in logs (`Log.d`, `Log.v`), clipboard, or backups
- [ ] `android:allowBackup="false"` and `FLAG_SECURE` on sensitive Activities
- [ ] Database encryption (SQLCipher) for sensitive records
- [ ] Keyboard cache disabled on sensitive fields (`inputType="textNoSuggestions"`)

| Anti-Pattern | Risk | Fix |
|---|---|---|
| `MODE_WORLD_READABLE` | Data accessible by any app | `MODE_PRIVATE` only |
| Logging tokens via `Log.d()` | Tokens in logcat | Remove in release builds |
| `android:allowBackup="true"` | Backup extraction via ADB | Set to `false` |
