---
name: security-audit
description: >
  Android application security audit and secure coding guidance based on OWASP MASVS v2.0
  and Kotlin secure coding practices. Triggers when writing or reviewing code involving
  sensitive data storage, cryptography, authentication, network communication, platform
  interaction (Intent, Content Provider, WebView), code quality, reverse engineering
  resilience, or user privacy. Also triggers on keywords like "security", "vulnerability",
  "pentest", "hardening", "obfuscation", "certificate pinning", "keystore", "biometric".
model: sonnet
---

# Android Security Audit Skill (OWASP MASVS v2.0)

Comprehensive security audit guidance covering all 8 MASVS categories with Kotlin code examples, anti-patterns, and actionable checklists.

**Reference**: [OWASP MASVS v2.0](https://mas.owasp.org/MASVS/)

---

## 1. MASVS-STORAGE: Secure Data Storage

Sensitive data (credentials, tokens, PII) must never be stored in plaintext or world-readable locations.

### Bad: Plaintext SharedPreferences

```kotlin
// BAD: Plaintext storage of sensitive data
val prefs = context.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
prefs.edit().putString("auth_token", "eyJhbGciOiJIUzI1NiIs...").apply()
prefs.edit().putString("password", "hunter2").apply()
```

### Good: EncryptedSharedPreferences + Android Keystore

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

### Checklist

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

---

## 2. MASVS-CRYPTO: Cryptography

Use strong, modern algorithms. Never hardcode keys. Never roll your own crypto.

### Bad: Hardcoded Key + ECB Mode

```kotlin
// BAD: Hardcoded key, ECB mode (deterministic), no IV
val secretKey = "MyS3cr3tK3y12345".toByteArray()
val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(secretKey, "AES"))
```

### Good: Android Keystore + AES-GCM

```kotlin
// GOOD: Hardware-backed Keystore, AES-GCM with auto-generated IV
object SecureCrypto {
    private const val KEY_ALIAS = "app_encryption_key"

    fun generateKey() {
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256).build()
        KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
            .apply { init(spec) }.generateKey()
    }

    fun encrypt(plaintext: ByteArray): Pair<ByteArray, ByteArray> {
        val key = KeyStore.getInstance("AndroidKeyStore")
            .apply { load(null) }.getKey(KEY_ALIAS, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        return Pair(cipher.iv, cipher.doFinal(plaintext))
    }

    fun decrypt(iv: ByteArray, ciphertext: ByteArray): ByteArray {
        val key = KeyStore.getInstance("AndroidKeyStore")
            .apply { load(null) }.getKey(KEY_ALIAS, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, iv))
        return cipher.doFinal(ciphertext)
    }
}
```

### Checklist

- [ ] No hardcoded encryption keys, IVs, or salts in source code
- [ ] AES-256-GCM for symmetric encryption (not ECB, not CBC without HMAC)
- [ ] Keys stored in Android Keystore (hardware-backed when available)
- [ ] RSA >= 2048 bits; no MD5, SHA-1 (security), DES, 3DES, RC4
- [ ] Unique IV per encryption; `SecureRandom` for all crypto randomness
- [ ] PBKDF2/Argon2/scrypt for key derivation with sufficient iterations

| Anti-Pattern | Risk | Fix |
|---|---|---|
| Hardcoded `SecretKeySpec` | Key extraction via RE | Android Keystore |
| `AES/ECB/*` | Pattern leakage | `AES/GCM/NoPadding` |
| `java.util.Random` for crypto | Predictable | `java.security.SecureRandom` |
| Keys in `strings.xml` / `BuildConfig` | Trivially extractable | Android Keystore |

---

## 3. MASVS-AUTH: Authentication & Session Management

Use biometrics securely with CryptoObject binding. Handle token lifecycle properly.

### Bad: Biometric Without CryptoObject

```kotlin
// BAD: No CryptoObject = bypassable via Frida hook on callback
biometricPrompt.authenticate(promptInfo) // callback-only, no crypto proof
```

### Good: Biometric with CryptoObject Binding

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

### Good: Token Expiry and Refresh

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

### Checklist

- [ ] Biometric uses `CryptoObject` binding (not callback-only)
- [ ] `BIOMETRIC_STRONG` (Class 3) required for sensitive operations
- [ ] Access tokens expire in 15-60 minutes; refresh tokens encrypted and rotated
- [ ] Session invalidated on logout (client and server)
- [ ] Failed login attempts rate-limited
- [ ] Password fields use `inputType="textPassword"` (no autocomplete)

---

## 4. MASVS-NETWORK: Network Security

Enforce TLS 1.2+, certificate pinning, and block all cleartext traffic.

### Bad: Trusting All Certificates

```kotlin
// BAD: Disabling certificate validation = MITM wide open
val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
    override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
})
```

### Good: Network Security Config + Certificate Pinning

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors><certificates src="system" /></trust-anchors>
    </base-config>
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-12-31">
            <pin digest="SHA-256">BASE64_PRIMARY_PIN=</pin>
            <pin digest="SHA-256">BASE64_BACKUP_PIN=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

```kotlin
// GOOD: OkHttp CertificatePinner as defense-in-depth
val pinner = CertificatePinner.Builder()
    .add("api.example.com", "sha256/PRIMARY_PIN=")
    .add("api.example.com", "sha256/BACKUP_PIN=")
    .build()
val client = OkHttpClient.Builder().certificatePinner(pinner).build()
```

### Checklist

- [ ] `cleartextTrafficPermitted="false"` in network security config
- [ ] Certificate pinning with backup pins; no custom `TrustManager` bypasses
- [ ] No permissive `HostnameVerifier`; TLS 1.2+ enforced
- [ ] No sensitive data in URL query parameters; API keys in headers

| Anti-Pattern | Risk | Fix |
|---|---|---|
| `TrustManager` accepting all certs | MITM | System trust store + pinning |
| `HostnameVerifier { _, _ -> true }` | Hostname spoofing | Remove custom verifier |
| Tokens in URL query strings | Logged by proxies | `Authorization` header |
| Single pin without backup | Cert rotation breaks app | Always include backup pin |

---

## 5. MASVS-PLATFORM: Platform Interaction

Validate Intents, restrict exported components, secure Content Providers, harden WebViews.

### Bad: Exported Activity Without Validation

```kotlin
// BAD: Trusts incoming Intent blindly, loads arbitrary URLs
class DeepLinkActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        webView.loadUrl(intent.getStringExtra("url")!!) // Untrusted input
    }
}
```

### Good: Intent Validation

```kotlin
// GOOD: Allowlist-based URI validation
class DeepLinkActivity : AppCompatActivity() {
    private val allowedHosts = setOf("example.com", "www.example.com")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val uri = intent.data ?: run { finish(); return }
        if (uri.scheme != "https" || uri.host !in allowedHosts) { finish(); return }
        handleValidDeepLink(uri)
    }
}
```

### Good: Hardened WebView

```kotlin
// GOOD: Minimal permissions, domain-restricted navigation
webView.settings.apply {
    javaScriptEnabled = true // Only if required
    allowFileAccess = false
    allowContentAccess = false
    allowFileAccessFromFileURLs = false
    allowUniversalAccessFromFileURLs = false
    mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
}
webView.webViewClient = object : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        return request.url.host?.endsWith("example.com") != true // Block untrusted
    }
}
```

### Checklist

- [ ] Exported components have intent filters or permission checks
- [ ] Incoming Intent extras validated (type, range, allowlist)
- [ ] `PendingIntent` uses `FLAG_IMMUTABLE` (API 31+)
- [ ] Content Providers `exported="false"` unless sharing required; parameterized queries
- [ ] WebView file access disabled; navigation restricted to trusted domains
- [ ] `@JavascriptInterface` methods validate all input; no implicit broadcasts with sensitive data

---

## 6. MASVS-CODE: Code Quality & Build Settings

Harden release builds. Enable R8/ProGuard. Remove debug artifacts.

### Bad/Good: Build Configuration

```kotlin
// BAD: Debug logging in production
Log.d("Payment", "Processing: amount=$amount, card=$cardNumber")

// GOOD: Debug-only logging
if (BuildConfig.DEBUG) { Log.d("Payment", "Processing payment initiated") }
```

```kotlin
// build.gradle.kts - Release hardening
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            isDebuggable = false
        }
    }
}
```

### Checklist

- [ ] `isMinifyEnabled = true` and `isShrinkResources = true` for release
- [ ] `isDebuggable = false` for release; no `Log.d()`/`Log.v()` without `BuildConfig.DEBUG`
- [ ] ProGuard/R8 rules reviewed; no test code in release APK
- [ ] Dependency vulnerability scanning (Dependabot, Snyk, OWASP Dependency-Check)
- [ ] `StrictMode` in debug only; no `System.out.println` in production
- [ ] Stack traces not exposed to end users

---

## 7. MASVS-RESILIENCE: Reverse Engineering Resilience

Detect tampering, rooted devices, and debugger attachment. Verify app integrity.

### Good: Multi-Signal Root Detection

```kotlin
object RootDetector {
    private val ROOT_BINARIES = listOf("/system/xbin/su", "/system/bin/su", "/sbin/su")
    private val ROOT_PACKAGES = listOf("com.topjohnwu.magisk", "eu.chainfire.supersu")

    fun isDeviceRooted(context: Context): Boolean {
        return ROOT_BINARIES.any { File(it).exists() } ||
            ROOT_PACKAGES.any { runCatching { context.packageManager.getPackageInfo(it, 0) }.isSuccess } ||
            runCatching { Runtime.getRuntime().exec("su"); true }.getOrDefault(false)
    }
}
```

### Good: APK Signature Verification

```kotlin
object TamperDetector {
    private const val EXPECTED_HASH = "SHA256_OF_RELEASE_CERT"
    fun isAppTampered(context: Context): Boolean = runCatching {
        val sigs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                .signingInfo?.apkContentsSigners
        } else {
            @Suppress("DEPRECATION")
            context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES).signatures
        }
        val hash = sigs?.firstOrNull()?.let {
            Base64.encodeToString(MessageDigest.getInstance("SHA-256").digest(it.toByteArray()), Base64.NO_WRAP)
        }
        hash != EXPECTED_HASH
    }.getOrDefault(true)
}
```

### Checklist

- [ ] Multi-signal root detection; debugger detection (`Debug.isDebuggerConnected()`)
- [ ] Runtime APK signature verification; Play Integrity API for attestation
- [ ] Code obfuscation via R8; string encryption for sensitive constants
- [ ] Frida/Xposed detection; emulator detection for sensitive environments

| Anti-Pattern | Risk | Fix |
|---|---|---|
| Single root check | Trivially bypassable | Multi-signal detection |
| Client-only integrity | Patchable in APK | Server-side Play Integrity |
| No debugger detection | Runtime secret inspection | `Debug.isDebuggerConnected()` |

---

## 8. MASVS-PRIVACY: User Privacy

Minimize data collection, enforce consent, support data deletion.

### Bad: Over-Collection

```kotlin
// BAD: Collecting device IDs without consent or need
val deviceId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
val imei = telephonyManager.imei
analyticsService.track(deviceId, imei)
```

### Good: Privacy-Respecting Analytics + Consent

```kotlin
class PrivacyAwareAnalytics(private val consentManager: ConsentManager) {
    suspend fun trackEvent(eventName: String, properties: Map<String, String>) {
        if (!consentManager.hasAnalyticsConsent()) return
        val sanitized = properties.filterKeys { it in ALLOWED_KEYS }
        analyticsApi.track(event = eventName, properties = sanitized)
    }
    companion object {
        private val ALLOWED_KEYS = setOf("screen_name", "action_type", "app_version")
    }
}

class ConsentManager(private val encryptedPrefs: SharedPreferences) {
    fun hasAnalyticsConsent(): Boolean = encryptedPrefs.getBoolean("consent_analytics", false)
    fun revokeAllConsent() {
        encryptedPrefs.edit()
            .putBoolean("consent_analytics", false)
            .putBoolean("consent_crash", false)
            .putBoolean("consent_ads", false).apply()
    }
}
```

### Checklist

- [ ] Data minimization: collect only what is strictly necessary
- [ ] Granular user consent before analytics, location, or PII collection
- [ ] Purpose limitation: data used only for stated purpose
- [ ] Full data deletion supported (GDPR Art. 17, CCPA)
- [ ] No device identifiers without consent; privacy policy accessible in-app
- [ ] Third-party SDKs audited for data collection practices

---

## Audit Output Format

Report findings using this template:

```
### [SEVERITY] Finding Title

**Category**: MASVS-STORAGE | CRYPTO | AUTH | NETWORK | PLATFORM | CODE | RESILIENCE | PRIVACY
**Severity**: CRITICAL | HIGH | MEDIUM | LOW | INFO
**File**: path/to/file.kt:LineNumber
**CWE**: CWE-XXX

**Description**: What the vulnerability is and why it matters.
**Evidence**:
```kotlin
// Vulnerable code snippet
```
**Impact**: What an attacker could achieve.
**Remediation**:
```kotlin
// Fixed code
```
**References**: OWASP MASVS-XXXX, MSTG-XXXX-XXX
```

| Severity | Definition | Example |
|---|---|---|
| **CRITICAL** | Immediate exploitation, data breach likely | Hardcoded API keys, disabled TLS |
| **HIGH** | Exploitation feasible, significant impact | Missing pinning, plaintext storage |
| **MEDIUM** | Requires conditions, moderate impact | Missing root detection, verbose logs |
| **LOW** | Minor improvement, limited impact | Missing `FLAG_SECURE` |
| **INFO** | Best practice recommendation | Code style |

---

## 10 Common Android Security Anti-Patterns

1. **Hardcoded Secrets** - API keys/tokens in source or `strings.xml`. Extractable via `jadx`.
2. **Disabled Certificate Validation** - Custom `TrustManager`/`HostnameVerifier` accepting all. MITM.
3. **Plaintext Data Storage** - Tokens/PII in unencrypted SharedPreferences/SQLite/external storage.
4. **Exported Components Without Protection** - `exported="true"` without permissions. Any app can invoke.
5. **Insecure WebView** - `allowFileAccessFromFileURLs` + untrusted URLs. Local file theft, XSS.
6. **Biometric Bypass (No CryptoObject)** - Callback-only auth bypassable via Frida.
7. **Logging Sensitive Data** - `Log.d()` with tokens/PII in production. Readable via `adb logcat`.
8. **Deprecated Crypto** - MD5, DES, ECB, `java.util.Random`. Known practical attacks.
9. **Implicit Broadcasts with Sensitive Data** - Any app can intercept. Use explicit intents.
10. **No Integrity Verification** - No signature check, root detection, or Play Integrity. Trivial repackaging.

---

## Summary Checklist

### MASVS-STORAGE (7 items)
- [ ] S1: No plaintext passwords/tokens in SharedPreferences
- [ ] S2: EncryptedSharedPreferences for sensitive data
- [ ] S3: EncryptedFile for sensitive files; no external storage
- [ ] S4: No sensitive data in logs, clipboard, or backups
- [ ] S5: `allowBackup="false"` and `FLAG_SECURE` on sensitive screens
- [ ] S6: Database encryption for sensitive records
- [ ] S7: Keyboard suggestions disabled on sensitive fields

### MASVS-CRYPTO (6 items)
- [ ] C1: No hardcoded encryption keys, IVs, or salts
- [ ] C2: AES-256-GCM; keys in Android Keystore
- [ ] C3: RSA >= 2048; no MD5/SHA-1/DES/3DES/RC4
- [ ] C4: Unique IV per operation; `SecureRandom` only
- [ ] C5: PBKDF2/Argon2/scrypt for key derivation
- [ ] C6: No keys in `strings.xml` or `BuildConfig`

### MASVS-AUTH (6 items)
- [ ] A1: Biometric uses CryptoObject; BIOMETRIC_STRONG required
- [ ] A2: Short-lived access tokens (15-60 min)
- [ ] A3: Refresh tokens encrypted and rotated
- [ ] A4: Session invalidated on logout
- [ ] A5: Failed login rate limiting
- [ ] A6: Password fields disable autocomplete

### MASVS-NETWORK (6 items)
- [ ] N1: `cleartextTrafficPermitted="false"`
- [ ] N2: Certificate pinning with backup pins
- [ ] N3: No custom TrustManager/HostnameVerifier bypasses
- [ ] N4: TLS 1.2+ enforced
- [ ] N5: No sensitive data in URL parameters
- [ ] N6: API keys in headers, not URLs

### MASVS-PLATFORM (7 items)
- [ ] P1: Exported components have permissions or validation
- [ ] P2: Intent extras validated (type, range, allowlist)
- [ ] P3: PendingIntent uses FLAG_IMMUTABLE
- [ ] P4: Content Providers unexported; parameterized queries
- [ ] P5: WebView file access disabled; domain-restricted
- [ ] P6: `@JavascriptInterface` input validated
- [ ] P7: No implicit broadcasts with sensitive data

### MASVS-CODE (7 items)
- [ ] Q1: R8/ProGuard and resource shrinking enabled
- [ ] Q2: `isDebuggable = false` for release
- [ ] Q3: No `Log.d()`/`Log.v()` without `BuildConfig.DEBUG` guard
- [ ] Q4: No test code in release APK
- [ ] Q5: Dependency vulnerability scanning configured
- [ ] Q6: StrictMode in debug only
- [ ] Q7: Stack traces not exposed to users

### MASVS-RESILIENCE (6 items)
- [ ] R1: Multi-signal root detection
- [ ] R2: Debugger detection on sensitive operations
- [ ] R3: Runtime APK signature verification
- [ ] R4: Play Integrity API integrated
- [ ] R5: Code obfuscation and string encryption
- [ ] R6: Frida/Xposed and emulator detection

### MASVS-PRIVACY (6 items)
- [ ] V1: Data minimization enforced
- [ ] V2: Granular consent before collection
- [ ] V3: Purpose limitation enforced
- [ ] V4: Full data deletion supported (GDPR/CCPA)
- [ ] V5: No device identifiers without consent
- [ ] V6: Third-party SDKs audited; privacy policy in-app

**Total: 51 checklist items across 8 MASVS categories.**

---

## References

- [OWASP MASVS v2.0](https://mas.owasp.org/MASVS/)
- [OWASP MASTG](https://mas.owasp.org/MASTG/)
- [Android Security Best Practices](https://developer.android.com/privacy-and-security/security-tips)
- [Android Keystore System](https://developer.android.com/privacy-and-security/keystore)
- [Network Security Configuration](https://developer.android.com/privacy-and-security/security-config)
- [BiometricPrompt](https://developer.android.com/identity/sign-in/biometric-auth)
- [Play Integrity API](https://developer.android.com/google/play/integrity)

---

**Security is not a feature you bolt on at the end. It is a property of the system designed in from day one. Every line handling sensitive data, network communication, or platform interaction is an attack surface. Treat it accordingly.**
