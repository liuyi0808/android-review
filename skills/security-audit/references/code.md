# MASVS-CODE: Code Quality & Build Settings

Harden release builds. Enable R8/ProGuard. Remove debug artifacts.

## Bad/Good: Build Configuration

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

## Checklist

- [ ] `isMinifyEnabled = true` and `isShrinkResources = true` for release
- [ ] `isDebuggable = false` for release; no `Log.d()`/`Log.v()` without `BuildConfig.DEBUG`
- [ ] ProGuard/R8 rules reviewed; no test code in release APK
- [ ] Dependency vulnerability scanning (Dependabot, Snyk, OWASP Dependency-Check)
- [ ] `StrictMode` in debug only; no `System.out.println` in production
- [ ] Stack traces not exposed to end users
