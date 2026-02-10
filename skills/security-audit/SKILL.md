---
name: security-audit
description: >-
  Android application security audit based on OWASP MASVS v2.0 and Kotlin secure
  coding practices. Use when: writing or reviewing code involving sensitive data
  storage (SharedPreferences, Room), cryptography (encryption keys, Keystore),
  authentication (biometrics, token management), network security (TLS, cert pinning),
  WebView hardening, Content Provider security, reverse engineering resilience
  (root detection, tamper detection), or user privacy (data minimization, consent).
---

# Android Security Audit Skill (OWASP MASVS v2.0)

Comprehensive security audit guidance covering all 8 MASVS categories with Kotlin code examples, anti-patterns, and actionable checklists.

**Reference**: [OWASP MASVS v2.0](https://mas.owasp.org/MASVS/)

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

## Reference Guide — Load on Demand

Each reference file contains Bad/Good code examples, anti-pattern tables, and detailed checklists. **Read the relevant file when auditing that category.**

| # | Reference File | MASVS Category | When to Load |
|---|---------------|----------------|-------------|
| 1 | [references/storage.md](references/storage.md) | MASVS-STORAGE | SharedPreferences, file storage, backups, logs |
| 2 | [references/crypto.md](references/crypto.md) | MASVS-CRYPTO | Encryption keys, Keystore, algorithms, IVs |
| 3 | [references/auth.md](references/auth.md) | MASVS-AUTH | Biometrics, tokens, session management |
| 4 | [references/network.md](references/network.md) | MASVS-NETWORK | TLS, cert pinning, cleartext traffic |
| 5 | [references/platform.md](references/platform.md) | MASVS-PLATFORM | Intents, WebView, Content Providers |
| 6 | [references/code.md](references/code.md) | MASVS-CODE | Build config, R8, logging, debug artifacts |
| 7 | [references/resilience.md](references/resilience.md) | MASVS-RESILIENCE | Root detection, tamper detection, obfuscation |
| 8 | [references/privacy.md](references/privacy.md) | MASVS-PRIVACY | Data minimization, consent, GDPR/CCPA |

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

*Security is not a feature you bolt on at the end. It is a property of the system designed in from day one. Every line handling sensitive data, network communication, or platform interaction is an attack surface. Treat it accordingly.*

*For Google Play policy compliance, see the `play-store` skill.*
