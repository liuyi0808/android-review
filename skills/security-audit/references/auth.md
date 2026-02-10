# MASVS-AUTH: Authentication & Session Management

Use biometrics securely with CryptoObject binding. Handle token lifecycle properly.

## Bad: Biometric Without CryptoObject

```kotlin
// BAD: No CryptoObject = bypassable via Frida hook on callback
biometricPrompt.authenticate(promptInfo) // callback-only, no crypto proof
```

## Good: Biometric with CryptoObject Binding

```kotlin
// GOOD: Biometric tied to Keystore decryption via CryptoObject
val key = keyStore.getKey("biometric_key", null) as SecretKey
val cipher = Cipher.getInstance("AES/GCM/NoPadding")
cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, iv))
val cryptoObject = BiometricPrompt.CryptoObject(cipher)

val prompt = BiometricPrompt(activity, executor, object : AuthenticationCallback() {
    override fun onAuthenticationSucceeded(result: AuthenticationResult) {
        val decrypted = result.cryptoObject?.cipher?.doFinal(encryptedToken)
            ?: return onError("CryptoObject missing")
        onSuccess(decrypted)
    }
})
prompt.authenticate(promptInfo, cryptoObject) // Crypto-bound authentication
```

## Good: Token Expiry and Refresh

```kotlin
// GOOD: Short-lived tokens with encrypted storage and refresh
class TokenManager(private val encryptedPrefs: SharedPreferences) {
    fun isTokenExpired(): Boolean {
        val expiresAt = encryptedPrefs.getLong("token_expires_at", 0L)
        return System.currentTimeMillis() >= expiresAt
    }
    suspend fun getValidToken(authApi: AuthApi): Result<String> = runCatching {
        if (!isTokenExpired()) {
            return@runCatching requireNotNull(encryptedPrefs.getString("access_token", null))
        }
        val refreshToken = requireNotNull(encryptedPrefs.getString("refresh_token", null))
        val response = authApi.refreshToken(refreshToken)
        storeTokenInfo(response)
        response.accessToken
    }
    fun clearTokens() { encryptedPrefs.edit().clear().apply() }
}
```

## Checklist

- [ ] Biometric uses `CryptoObject` binding (not callback-only)
- [ ] `BIOMETRIC_STRONG` (Class 3) required for sensitive operations
- [ ] Access tokens expire in 15-60 minutes; refresh tokens encrypted and rotated
- [ ] Session invalidated on logout (client and server)
- [ ] Failed login attempts rate-limited
- [ ] Password fields use `inputType="textPassword"` (no autocomplete)
