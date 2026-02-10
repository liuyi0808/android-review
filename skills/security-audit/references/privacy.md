# MASVS-PRIVACY: User Privacy

Minimize data collection, enforce consent, support data deletion.

## Bad: Over-Collection

```kotlin
// BAD: Collecting device IDs without consent or need
val deviceId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
val imei = telephonyManager.imei
analyticsService.track(deviceId, imei)
```

## Good: Privacy-Respecting Analytics + Consent

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

## Checklist

- [ ] Data minimization: collect only what is strictly necessary
- [ ] Granular user consent before analytics, location, or PII collection
- [ ] Purpose limitation: data used only for stated purpose
- [ ] Full data deletion supported (GDPR Art. 17, CCPA)
- [ ] No device identifiers without consent; privacy policy accessible in-app
- [ ] Third-party SDKs audited for data collection practices
