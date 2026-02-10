# MASVS-RESILIENCE: Reverse Engineering Resilience

Detect tampering, rooted devices, and debugger attachment. Verify app integrity.

## Good: Multi-Signal Root Detection

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

## Good: APK Signature Verification

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

## Checklist

- [ ] Multi-signal root detection; debugger detection (`Debug.isDebuggerConnected()`)
- [ ] Runtime APK signature verification; Play Integrity API for attestation
- [ ] Code obfuscation via R8; string encryption for sensitive constants
- [ ] Frida/Xposed detection; emulator detection for sensitive environments

| Anti-Pattern | Risk | Fix |
|---|---|---|
| Single root check | Trivially bypassable | Multi-signal detection |
| Client-only integrity | Patchable in APK | Server-side Play Integrity |
| No debugger detection | Runtime secret inspection | `Debug.isDebuggerConnected()` |
