# Build Configuration & App Signing

## Table of Contents
- [1. Build Configuration](#1-build-configuration)
  - [1.1 Target API Level](#11-target-api-level-mandatory)
  - [1.2 App Bundle Format](#12-app-bundle-format-mandatory)
  - [1.3 Billing Library](#13-billing-library-if-applicable)
  - [1.4 Release Build Checklist](#14-release-build-checklist)
  - [1.5 16 KB Memory Page Compatibility](#15-16-kb-memory-page-compatibility)
- [2. App Signing](#2-app-signing)
  - [2.1 Play App Signing](#21-play-app-signing-mandatory-for-new-apps)
  - [2.2 Key Management](#22-key-management)

---

## 1. Build Configuration

### 1.1 Target API Level (Mandatory)

For mobile apps, including personal loan apps, the [Google Play target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878) effective **August 31, 2026** are:

| Audit scenario | Minimum target API | Impact if below the minimum |
|---|---|---|
| New app or update submission | API 36 (Android 16) | Submission blocked |
| Existing app without a new submission | API 35 (Android 15) | Existing app unavailable to new users on devices with Android versions higher than its target API |

The general extension ended **November 1, 2026**. Permanently private organization apps have a separate exception. For other form factors, use the applicable table in the official source rather than applying the mobile numbers unconditionally.

```kotlin
// build.gradle.kts
android {
    compileSdk = 36
    defaultConfig {
        targetSdk = 36
        minSdk = 24
    }
}
```

**Audit evidence**: Record the release scenario, form factor, version code and effective `targetSdkVersion` from Play Console or the submitted variant's merged or packaged manifest. `compileSdk`, product-flavor defaults and source grep results alone are not proof. Verify any claimed exception. Record missing artifact or Console evidence as `NEEDS_CONFIRMATION`; do not treat an availability restriction as removal or as the update threshold.

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

For apps that use Google Play Billing, the [Play Billing Library version deprecation schedule](https://developer.android.com/google/play/billing/deprecation-faq) requires **version 8 or later** for new app and update submissions starting **August 31, 2026**. The general extension ended **November 1, 2026**. An existing version remaining on the store is not blocked solely because it uses a deprecated library; evaluate a new submission separately. Verify the version resolved for the submitted variant, including billing supplied transitively by an SDK, and any discrepancy reported in Play Console. Recheck the schedule for the planned submission date.

Ordinary loan repayment is not itself a Play Billing integration. Evaluate covered digital purchases or subscriptions separately.

**Note (U.S. market)**: As of September 2025, the Epic Games injunction allows alternative billing systems for U.S. users. Developers must comply with updated linking/billing policies by January 28, 2026 if using alternatives.

### 1.4 Release Build Checklist

- [ ] `isMinifyEnabled = true` (R8 enabled)
- [ ] `isShrinkResources = true`
- [ ] `isDebuggable = false` (default for release, verify explicitly)
- [ ] No `StrictMode` enabled in release
- [ ] No test/debug API endpoints reachable in release build
- [ ] Verify the submitted `versionCode` against Play Console release history. It must be unused, higher than the version it replaces and at most [2,100,000,000](https://support.google.com/googleplay/android-developer/answer/17367361).
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

### 1.5 16 KB Memory Page Compatibility

The [Android Developers guide](https://developer.android.com/guide/practices/page-sizes#requirements) requires Google Play apps targeting API 35+ to support 16 KB memory page sizes on 64-bit devices. Google states that updates that do not support 16 KB cannot be released starting **February 1, 2027**. Record any existing Console warning or restriction separately. This is a binary compatibility check, not the Play Vitals memory-use threshold in `deployment.md` §17.4.1.

- Inspect the intended uploaded AAB and its generated APKs, including feature modules and native libraries from SDKs (for example, KYC, camera, or image processing). A Kotlin/Java-only source tree does not establish that the packaged app has no native code. If the inspected artifact has no native code, record that evidence; native ELF checks are then not applicable.
- For packaged 64-bit `.so` files, check ELF load-segment alignment using the official `check_elf_alignment.sh` or `llvm-objdump -p`. Check the bundle's packaging alignment (`bundletool dump config --bundle=<existing.aab>`; expect `PAGE_ALIGNMENT_16K` when shipping uncompressed native libraries) and verify ZIP alignment of generated APKs using `zipalign -c -P 16 -v 4 <existing.apk>`. Compressed library packaging does not waive ELF compatibility. Build-tool versions alone do not prove the actual libraries pass.
- Exercise the SDK-dependent flows on a supported 16 KB device or emulator. Confirm the test environment with `adb shell getconf PAGE_SIZE` (`16384`); installation or launch in compatibility mode is not proof of native support. Use existing artifacts for packaging checks and Debug builds for local runtime testing; do not run a Release build for the audit.
- Record version, packaging and ELF results, runtime evidence and Console status separately. Unavailable evidence is `NEEDS_CONFIRMATION`. Report confirmed gaps as readiness work before enforcement; record any verified current publishing block separately.

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

**Code audit**: Review `storePassword` and `keyPassword` in the audited signing configuration. Use [`scripts/audit.sh`](../scripts/audit.sh) for redacted literal-assignment locations. Trace configured environment or Gradle property providers separately and keep credentials out of the report.
