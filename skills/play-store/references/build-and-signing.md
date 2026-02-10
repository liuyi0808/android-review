# Build Configuration & App Signing

## Table of Contents
- [1. Build Configuration](#1-build-configuration)
  - [1.1 Target API Level](#11-target-api-level-mandatory)
  - [1.2 App Bundle Format](#12-app-bundle-format-mandatory)
  - [1.3 Billing Library](#13-billing-library-if-applicable)
  - [1.4 Release Build Checklist](#14-release-build-checklist)
- [2. App Signing](#2-app-signing)
  - [2.1 Play App Signing](#21-play-app-signing-mandatory-for-new-apps)
  - [2.2 Key Management](#22-key-management)

---

## 1. Build Configuration

### 1.1 Target API Level (Mandatory)

From August 31, 2025:
- **New apps and updates** MUST target API 35 (Android 15) or higher
- **Existing apps** MUST target at least API 34 to remain visible on Android 15+ devices
- Wear OS / Android TV / Automotive: API 34 minimum
- Extension available in Play Console to November 1, 2025

```kotlin
// build.gradle.kts
android {
    compileSdk = 35
    defaultConfig {
        targetSdk = 35
        minSdk = 24
    }
}
```

**Code audit**: Check `build.gradle` / `build.gradle.kts` for `targetSdk` value. Search for `targetSdkVersion` in legacy Groovy files.

### 1.2 App Bundle Format (Mandatory)

Google Play requires AAB (Android App Bundle), NOT APK:

```kotlin
android {
    bundle {
        language { enableSplit = true }
        density { enableSplit = true }
        abi { enableSplit = true }
    }
}
```

### 1.3 Billing Library (if applicable)

Apps with in-app purchases MUST use Play Billing Library 7.0.0+:
```kotlin
implementation("com.android.billingclient:billing-ktx:7.1.1")
```

**Note (U.S. market)**: As of September 2025, the Epic Games injunction allows alternative billing systems for U.S. users. Developers must comply with updated linking/billing policies by January 28, 2026 if using alternatives.

### 1.4 Release Build Checklist

- [ ] `isMinifyEnabled = true` (R8 enabled)
- [ ] `isShrinkResources = true`
- [ ] `isDebuggable = false` (default for release, verify explicitly)
- [ ] No `StrictMode` enabled in release
- [ ] No test/debug API endpoints reachable in release build
- [ ] Version code incremented from previous release
- [ ] ProGuard/R8 mapping file saved for crash deobfuscation
- [ ] No `Log.d()` / `Log.v()` without `BuildConfig.DEBUG` guard in release code
- [ ] No unguarded `printStackTrace()` in release code

**Code audit**:
```
# Check debuggable flag
grep -r "debuggable" build.gradle* build-script/

# Check for debug endpoints
grep -rn "sandbox\|staging\|debug.*url\|test.*api" --include="*.kt" app/src/main/
```

**Log guard verification methodology**:

Simple `grep | grep -v "BuildConfig.DEBUG"` produces **false positives** because `BuildConfig.DEBUG` is often on the preceding line, not the same line as `Log.*`. Use context-aware checking instead:

```
# Step 1: Find ALL Log.d/v/i/e calls with 3 lines of context BEFORE each match
grep -rn -B 3 "Log\.\(d\|v\|i\|e\|w\)(" --include="*.kt" app/src/main/

# Step 2: For each match, verify one of these guard patterns exists within 1-3 lines above:
#   Pattern A (same line):    if (BuildConfig.DEBUG) Log.d(...)
#   Pattern B (block guard):  if (BuildConfig.DEBUG) { \n ... \n Log.d(...)
#   Pattern C (class-level):  The entire class/method is only invoked from debug paths
#                             (e.g., a HttpLogInterceptor only added in debug builds)

# Step 3: Also check printStackTrace() with context
grep -rn -B 3 "printStackTrace" --include="*.kt" app/src/main/
```

**CRITICAL**: Do NOT report a `Log.*` call as unguarded without reading the surrounding 3 lines of context. A `Log.d(...)` inside an `if (BuildConfig.DEBUG) { ... }` block is properly guarded even though the Log line itself does not contain `BuildConfig.DEBUG`. When using subagents for this check, explicitly instruct them to verify the context window, not just the matching line.

**What counts as properly guarded**:
- `if (BuildConfig.DEBUG) Log.d(...)` — single line ✅
- `if (BuildConfig.DEBUG) { \n Log.d(...) \n }` — block ✅
- Log call inside a class/method only reachable from debug build paths (e.g., `DebugHttpLogInterceptor`) — ✅ but must verify the caller chain
- `Log.d(...)` with no guard in any of the above patterns — ❌ UNGUARDED

**What to actually flag**:
- `Log.d/v/i` with NO `BuildConfig.DEBUG` guard in any form → WARNING
- `Log.e` / `printStackTrace()` with NO guard → INFO (less severe, but still leaks stack traces)
- Log calls inside classes that are only used in debug builds → OK, but verify the caller chain

---

## 2. App Signing

### 2.1 Play App Signing (Mandatory for new apps)

All new apps MUST use Play App Signing. Google manages the app signing key.

```
Upload key (you keep) → signs AAB for upload
App signing key (Google keeps) → signs final APK for distribution
```

### 2.2 Key Management

- [ ] Upload key stored securely (NOT in version control)
- [ ] Upload key password NOT hardcoded in build scripts
- [ ] Backup of upload key exists in secure location
- [ ] If upload key is lost: request reset through Play Console (requires identity verification)
- [ ] Debug keystore credentials NOT committed to repo

**Code audit**: Check `build.gradle` signing configs for hardcoded passwords:
```
grep -rn "storePassword\|keyPassword\|keyAlias" --include="*.gradle*"
```
