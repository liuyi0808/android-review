# Baseline Profiles

## Purpose

Pre-compile hot code paths for 30-40% faster startup and smoother scrolling.

## Setup

```kotlin
// build.gradle.kts (app module)
dependencies {
    implementation("androidx.profileinstaller:profileinstaller:1.4.1")
    baselineProfile(project(":baselineprofile"))
}

// Create :baselineprofile module
// BaselineProfileGenerator.kt
@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {
    @get:Rule
    val rule = BaselineProfileRule()

    @Test
    fun generateBaselineProfile() {
        rule.collect("com.example.app") {
            // Critical user journey
            pressHome()
            startActivityAndWait()
            // Navigate through key screens
            device.findObject(By.text("Login")).click()
            device.waitForIdle()
        }
    }
}
```

## Checklist

- [ ] `profileinstaller` dependency added
- [ ] Baseline profile generator covers critical paths (startup, main list, navigation)
- [ ] Profile generated and included in release build
- [ ] Startup time measured before/after profile
