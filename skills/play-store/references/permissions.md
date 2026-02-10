# Sensitive & Restricted Permissions (CRITICAL)

## Table of Contents
- [3.1 SMS & Call Log Permissions](#31-sms--call-log-permissions-heavily-restricted)
  - [3.1.1 Temporary Exception Use Cases](#311-temporary-exception-use-cases-non-default-handlers)
  - [3.1.2 Spyware Policy Constraints](#312-spyware-policy-constraints-critical-for-financial-apps)
  - [3.1.3 Personal Loan Apps — Additional Restrictions](#313-personal-loan-apps--additional-restrictions)
  - [3.1.4 Invalid Use Cases](#314-invalid-use-cases-will-be-rejected)
  - [3.1.5 Recommended Alternatives](#315-recommended-alternatives)
  - [3.1.6 Declaration Process](#316-declaration-process)
  - [3.1.7 Checklist](#317-checklist)
- [3.2 QUERY_ALL_PACKAGES](#32-query_all_packages-installed-apps-visibility)
- [3.3 Photo & Video Permissions](#33-photo--video-permissions-updated-january-2025)
- [3.4 Location Permissions](#34-location-permissions)
- [3.5 Camera Permission](#35-camera-permission)
- [3.6 Foreground Service Types](#36-foreground-service-types-android-14--api-34)
- [3.7 Exact Alarm Permissions](#37-exact-alarm-permissions)
- [3.8 Full-Screen Intent Permission](#38-full-screen-intent-permission-january-2025)
- [3.9 Permissions Checklist Summary](#39-permissions-checklist-summary)

---

This section covers permissions that trigger **mandatory Play Console declarations** and may cause **immediate rejection** if misused.

### 3.1 SMS & Call Log Permissions (Heavily Restricted)

**Policy**: SMS/Call Log permissions (`READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS`) are restricted to apps that are the **default SMS/Phone/Assistant handler**. However, Google provides a **temporary exception** mechanism for non-default-handler apps whose core functionality requires these permissions and no alternative method exists.

#### 3.1.1 Temporary Exception Use Cases (Non-Default Handlers)

Google Play may grant temporary exceptions for specific use cases listed in the official exception table. Key financial-related exceptions include:

| Exception Category | Permitted Use | Required Permissions |
|---|---|---|
| **SMS-based financial transactions** | Financial transactions via SMS (e.g., 5-digit bank messages), OTP account verification for financial transactions, fraud detection | `READ_SMS`, `RECEIVE_SMS`, `SEND_SMS` |
| **Money management / budgeting** | Track, budget, manage SMS-based financial transactions (e.g., 5-digit messages) and related account verification | `READ_SMS`, `RECEIVE_SMS` |

**Requirements for exception approval**:
1. SMS/Call Log access must enable **core app functionality** (without which the app is broken or unusable)
2. There must be **no alternative method** to provide the core functionality
3. The app's description must **prominently document** the core feature requiring SMS access
4. Must submit **Permissions Declaration Form** in Play Console with clear justification
5. Exception APKs must represent a **very small percentage** (low single-digit %) of total install base
6. Exceptions are granted **case-by-case** and are rarely approved — Google explicitly states this

#### 3.1.2 Spyware Policy Constraints (CRITICAL for Financial Apps)

Even when granted an SMS exception, **all apps must comply with the Spyware Policy**:

> "Personal loans or budgeting apps may **not exfiltrate or share non-financial or personal SMS history** of a user."

This means:
- **Allowed**: Reading bank transaction SMS (5-digit numbers), OTP verification for financial transactions
- **PROHIBITED**: Accessing personal SMS messages, sharing SMS data with third parties for non-core purposes, using SMS data for advertising/marketing, credit scoring based on SMS content analysis

Data use restrictions:
- Transfer, sharing, or licensed use of SMS data must **only** be for providing core features within the app
- Use may **not** be extended for any other purpose (improving other apps, advertising, marketing)

#### 3.1.3 Personal Loan Apps — Additional Restrictions

The **Personal Loans policy** (separate from SMS/Call Log policy) explicitly prohibits personal loan apps from accessing certain sensitive data for risk assessment:

**Prohibited permissions for personal loan apps** (since May 31, 2023, updated April 2025):
- `READ_CONTACTS` / `WRITE_CONTACTS`
- `READ_PHONE_NUMBERS`
- `ACCESS_FINE_LOCATION`
- `READ_EXTERNAL_STORAGE`
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`

**Note on `READ_SMS` for loan apps**: `READ_SMS` is NOT in the explicit Personal Loans prohibited permissions list above. It is governed by the separate **SMS/Call Log permission policy** (Section 3.1.1). However, personal loan apps face heightened scrutiny:
- Using SMS data for **credit scoring or lending decisions** is prohibited under the Spyware Policy
- SMS access purely for **transaction verification or OTP** may qualify for exception, but approval is case-by-case and rare
- Google's ML review system cross-checks actual SMS usage patterns against declared purposes

#### 3.1.4 Invalid Use Cases (Will Be Rejected)

These use cases will NOT be approved regardless of app type:
- Account verification via SMS content (use SMS Retriever API instead)
- Content sharing or invitations via SMS
- Contact prioritization when not the default handler
- Credit scoring based on SMS history analysis
- Sharing SMS data with third parties for non-core purposes

#### 3.1.5 Recommended Alternatives

**For OTP auto-fill** (recommended for ALL apps):
```kotlin
// SMS Retriever API — does NOT require READ_SMS permission
val client = SmsRetriever.getClient(context)
val task = client.startSmsRetriever()
```

**For financial transaction tracking** (if exception not feasible):
- Manual transaction entry by user
- Bank API integration (Open Banking)
- Transaction notification parsing via Notification Listener Service

#### 3.1.6 Declaration Process

If your app requires SMS/Call Log permissions:
1. Submit **Permissions Declaration Form** in Play Console
2. If use case is not listed in the standard form, submit **New use case form**
3. Provide clear documentation of core functionality
4. Include demo video showing the feature in action
5. Explain why no alternative method exists

**Code audit**:
```
# HIGH RISK — requires Permissions Declaration Form and exception approval:
grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|READ_CALL_LOG" AndroidManifest.xml

# BLOCKER for loan apps — prohibited by Personal Loans policy:
grep -n "READ_CONTACTS\|WRITE_CONTACTS\|READ_PHONE_NUMBERS" AndroidManifest.xml

# Check for SMS content access in code:
grep -rn "Telephony.Sms\|SmsMessage\|pdus" --include="*.kt"
```

#### 3.1.7 Checklist

- [ ] Verify if SMS/Call Log permissions are truly needed for core functionality
- [ ] If needed: Permissions Declaration Form submitted with detailed justification
- [ ] If loan app: Confirm `READ_SMS` is NOT used for credit scoring or lending decisions
- [ ] SMS Retriever API used for OTP auto-fill (preferred over `READ_SMS`)
- [ ] No `READ_CALL_LOG` / `WRITE_CALL_LOG` unless exception approved
- [ ] App does NOT exfiltrate non-financial or personal SMS content
- [ ] SMS data not shared with third parties for advertising/marketing
- [ ] App description prominently documents SMS-dependent core features
- [ ] Personal loan apps: No `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES` in manifest

### 3.2 QUERY_ALL_PACKAGES (Installed Apps Visibility)

**Policy**: Broad app visibility via `QUERY_ALL_PACKAGES` is restricted to specific use cases requiring interoperability with all apps.

**For loan/financial apps**: Google **explicitly states** that use for personal loans, credit assessment, or facilitating access to personal loans is **NOT eligible** for the financial-transactions exception.

**Code audit**:
```
# BLOCKER for loan apps:
grep -n "QUERY_ALL_PACKAGES" AndroidManifest.xml

# Check for <queries> block size - excessive package queries raise flags:
grep -c "<package android:name" AndroidManifest.xml
```

**Alternative**: Use targeted `<queries>` blocks with only the specific packages needed for documented interoperability.

- [ ] No `QUERY_ALL_PACKAGES` permission in loan apps
- [ ] `<queries>` block limited to packages with documented business justification
- [ ] Permissions Declaration Form submitted if broad visibility needed

### 3.3 Photo & Video Permissions (Updated January 2025)

**Policy effective May 28, 2025**: Apps with `READ_MEDIA_IMAGES` or `READ_MEDIA_VIDEO` must either:
1. Use **Android Photo Picker** (for one-time/infrequent access like profile photo upload)
2. Submit a **declaration form** in Play Console for broad access (only if core functionality)

**For loan apps**: Photo access for KYC document upload is considered "one-time use" — use Photo Picker or CameraX, NOT broad media permissions.

**Code audit**:
```
# Check for broad photo/video permissions:
grep -n "READ_MEDIA_IMAGES\|READ_MEDIA_VIDEO\|READ_EXTERNAL_STORAGE" AndroidManifest.xml
```

- [ ] Use Photo Picker (`androidx.activity:activity:1.7.0+`) for image selection
- [ ] Use CameraX for document capture (no gallery access needed)
- [ ] No `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` unless declared and approved
- [ ] No `READ_EXTERNAL_STORAGE` (deprecated, use scoped storage)

### 3.4 Location Permissions

**Policy**: Location access must be core to app functionality and clearly disclosed.

**For loan apps**: Location for risk assessment may be acceptable with proper disclosure, but must be declared in Data Safety and explained to users.

- [ ] `ACCESS_FINE_LOCATION` only if precise location is core functionality
- [ ] `ACCESS_COARSE_LOCATION` preferred over fine location when possible
- [ ] No `ACCESS_BACKGROUND_LOCATION` unless absolutely necessary (triggers additional review)
- [ ] Pre-permission dialog explaining why location is needed
- [ ] Graceful degradation when location denied

### 3.5 Camera Permission

- [ ] Camera permission only for documented functionality (KYC photos, document scanning)
- [ ] Pre-permission dialog explaining camera use
- [ ] CameraX used for capture (not deprecated Camera API)

### 3.6 Foreground Service Types (Android 14+ / API 34+)

**Policy**: Apps targeting API 34+ MUST declare a `foregroundServiceType` for each foreground service in the manifest.

**Play Console requirement**: For each foreground service type, you must:
1. Provide a description of the functionality
2. Include a link to a demo video showing the feature
3. Explain user impact

Available types: `camera`, `connectedDevice`, `dataSync`, `health`, `location`, `mediaPlayback`, `mediaProjection`, `microphone`, `phoneCall`, `remoteMessaging`, `shortService`, `specialUse`, `systemExempted`

```xml
<!-- Manifest declaration required -->
<service
    android:name=".MyService"
    android:foregroundServiceType="location|dataSync" />
```

**Code audit**:
```
# Check for foreground services without type:
grep -n "FOREGROUND_SERVICE" AndroidManifest.xml
grep -n "<service" AndroidManifest.xml | grep -v "foregroundServiceType"
```

- [ ] All foreground services declare explicit `foregroundServiceType`
- [ ] `FOREGROUND_SERVICE_<TYPE>` permission declared for each type
- [ ] Play Console FGS declaration form completed with video demo

### 3.7 Exact Alarm Permissions

**Policy**: `USE_EXACT_ALARM` is restricted to alarm/timer/calendar core apps. Others must use `SCHEDULE_EXACT_ALARM` (user-granted, revocable).

- [ ] No `USE_EXACT_ALARM` unless core alarm/timer functionality
- [ ] `SCHEDULE_EXACT_ALARM` check via `canScheduleExactAlarms()` before use
- [ ] Fallback to inexact alarms when exact alarm denied

### 3.8 Full-Screen Intent Permission (January 2025)

**Policy**: Starting January 22, 2025, for apps targeting API 34+, `USE_FULL_SCREEN_INTENT` is only auto-granted for calling/alarm apps. Others must request user permission.

- [ ] No `USE_FULL_SCREEN_INTENT` unless calling or alarm functionality
- [ ] Use high-priority notifications instead for non-calling/alarm use cases

### 3.9 Permissions Checklist Summary

- [ ] Every permission in manifest has documented business justification
- [ ] Pre-permission rationale dialog shown before runtime permission requests
- [ ] App functions gracefully when ANY permission is denied
- [ ] All Permissions Declaration Forms submitted in Play Console
- [ ] No permissions declared "just in case" — unused permissions removed
