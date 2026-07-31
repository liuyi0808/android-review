# Sensitive & Restricted Permissions (CRITICAL)

## Table of Contents
- [3.1 SMS & Call Log Permissions](#31-sms--call-log-permissions-heavily-restricted)
  - [3.1.1 Temporary Exception Use Cases](#311-temporary-exception-use-cases-non-default-handlers)
  - [3.1.2 Spyware Policy Constraints](#312-spyware-policy-constraints-critical-for-financial-apps)
  - [3.1.3 Personal Loan Apps — Additional Restrictions](#313-personal-loan-apps--additional-restrictions)
  - [3.1.4 Invalid Use Cases](#314-invalid-use-cases-will-be-rejected)
  - [3.1.5 Financial App SMS History Restrictions](#315-financial-app-sms-history-restrictions)
  - [3.1.6 Recommended Alternatives](#316-recommended-alternatives)
  - [3.1.7 Declaration Process](#317-declaration-process)
  - [3.1.8 Checklist](#318-checklist)
- [3.2 QUERY_ALL_PACKAGES](#32-query_all_packages-installed-apps-visibility)
- [3.3 Photo & Video Permissions](#33-photo--video-permissions-announced-oct-2023-full-compliance-may-2025)
- [3.4 Location Permissions](#34-location-permissions)
- [3.5 Camera Permission](#35-camera-permission)
- [3.6 Foreground Service Types](#36-foreground-service-types-android-14--api-34)
- [3.7 Exact Alarm Permissions](#37-exact-alarm-permissions)
- [3.8 Full-Screen Intent Permission](#38-full-screen-intent-permission-january-2025)
- [3.9 Contacts Permissions (NEW, effective Oct 28, 2026)](#39-contacts-permissions-new-effective-oct-28-2026)
- [3.10 Permissions Checklist Summary](#310-permissions-checklist-summary)

---

This section covers permissions that trigger **mandatory Play Console declarations** and may cause **immediate rejection** if misused.

### 3.1 SMS & Call Log Permissions (Heavily Restricted)

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16558241)): SMS and Call Log Permissions are regarded as personal and sensitive user data. Apps lacking default SMS, Phone, or Assistant handler capability may not declare use of these permissions in the manifest. This includes placeholder text in the manifest. Apps must be actively registered as the default handler before prompting users to accept any of these permissions and must immediately stop using the permission when they're no longer the default handler.

Apps may only use the permission (and any data derived from it) to provide approved core app functionality. Core functionality is defined as the main purpose of the app — without the core feature(s), the app is "broken" or rendered unusable. The transfer, sharing, or licensed use of this data must only be for providing core features or services within the app, and its use may not be extended for any other purpose (for example, improving other apps or services, advertising, or marketing purposes). You may not use alternative methods (including other permissions, APIs, or third-party sources) to derive data attributed to Call Log or SMS related permissions.

#### 3.1.1 Temporary Exception Use Cases (Non-Default Handlers)

Google Play may provide a temporary exception to apps that aren't Default SMS, Phone, or Assistant handlers when:
1. Use of the permission enables the core app functionality listed in the exception table, **and**
2. There's currently no alternative method to provide the core functionality.

**Financial-related exceptions** ([source](https://support.google.com/googleplay/android-developer/answer/10208820)):

| Exception Category | Description (official) | Eligible Permissions |
|---|---|---|
| **SMS-based financial transactions** | For example, Unified Payments Interface (UPI), verifications for financial transactions | `READ_SMS`, `RECEIVE_MMS`, `RECEIVE_SMS`, `RECEIVE_WAP_PUSH`, `SEND_SMS` |
| ~~**Call-based authentication and authorization in banking or brokerage apps**~~ | ⚠️ **REMOVED July 15, 2026** ([source](https://support.google.com/googleplay/android-developer/answer/17134731)): `READ_CALL_LOG` is no longer permitted for account verification via phone call. Google removed this exception because secure alternatives now exist — use [Digital Credentials API](https://developer.android.com/identity/sign-in/credential-manager) or [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview) instead. Apps still using this permission for verification have 30 days from July 15, 2026 to migrate. | ~~`READ_CALL_LOG`, `PROCESS_OUTGOING_CALLS`~~ |
| **SMS-based money management** | For example, apps that track and manage budget | `READ_SMS`, `RECEIVE_MMS`, `RECEIVE_SMS`, `RECEIVE_WAP_PUSH` |

> **Note**: All eligible permissions are subject to Google Play review and approval. The full exception table includes additional non-financial categories (caller ID, backup & restore, connected device companion, device automation, enterprise archive, etc.) — see [full list](https://support.google.com/googleplay/android-developer/answer/10208820).

**Requirements for exception approval**:
1. SMS/Call Log access must enable **core app functionality** (without which the app is broken or unusable)
2. There must be **no alternative method** to provide the core functionality
3. The app's description must **prominently document and promote** the core feature(s) requiring SMS access
4. Must submit **[Permissions Declaration Form](https://support.google.com/googleplay/android-developer/answer/9214102)** in Play Console
5. For **old APKs published before Jan 1, 2019** that cannot be modified: exception APKs must represent a very small percentage (no more than a low single-digit %) of total install base ([source](https://support.google.com/googleplay/android-developer/answer/10208820))
6. Google Play will review requests and grant exceptions on a **case-by-case basis**

#### 3.1.2 SMS & Call Log Policy Compliance

All SMS and Call Log use case exceptions, if granted, must comply with all existing Play policies ([source](https://support.google.com/googleplay/android-developer/answer/10208820)):

1. **[Spyware Policy](https://support.google.com/googleplay/android-developer/answer/9888380)** — prohibits exfiltration of data not related to policy-compliant functionality. For example, personal loans or budgeting apps may not exfiltrate or share non-financial or personal SMS history of a user. See [Understanding Google Play's Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000).
2. **[Permissions and APIs that Access Sensitive Information](https://support.google.com/googleplay/android-developer/answer/9888170)** — you may not use permissions or APIs that access sensitive information for undisclosed, unimplemented, or disallowed features or purposes.
3. **[User Data Policy Requirements](https://support.google.com/googleplay/android-developer/answer/10144311)** — includes Privacy Policy, Prominent Disclosure, and Consent requirements.

#### 3.1.3 Key Considerations — Do's & Don'ts

From the [Permissions and APIs that Access Sensitive Information](https://support.google.com/googleplay/android-developer/answer/16558241) policy:

| Do | Don't |
|----|-------|
| Submit a [declaration form](https://support.google.com/googleplay/android-developer/answer/9214102) in your Play Console | Don't request SMS/Call Log permissions without a core need justification |
| Clearly document the core functionality requiring access to your users | Don't use this data for advertising or other purposes |
| Use policy-compliant alternatives like the [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview) where possible | Don't store or share unnecessary SMS or Call Log data |
| Stop accessing data immediately upon losing default handler status | Don't attempt to derive this data using alternative methods |
| Review the [permitted uses and exceptions](https://support.google.com/googleplay/android-developer/answer/10208820) of the SMS and Call Log permissions | |

#### 3.1.4 Personal Loan Apps — Additional Restrictions

The **Personal Loans policy** (separate from SMS/Call Log policy) explicitly prohibits personal loan apps from accessing certain sensitive data for risk assessment:

**Prohibited permissions for personal loan apps** (since May 31, 2023, updated April 2025):
- `READ_CONTACTS`
- `READ_PHONE_NUMBERS`
- `ACCESS_FINE_LOCATION`
- `READ_EXTERNAL_STORAGE`
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`

**Note on `READ_SMS` for loan apps**: `READ_SMS` is NOT in the explicit Personal Loans prohibited permissions list above. It is governed by the separate **SMS/Call Log permission policy** (Section 3.1.1). However, personal loan apps face heightened scrutiny — the Spyware Policy explicitly states that personal loans or budgeting apps may not exfiltrate or share non-financial or personal SMS history of a user (Section 3.1.2).

#### 3.1.5 Financial App SMS Restrictions (Spyware Policy)

Google's [Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000) explicitly lists the following as a spyware violation:

> "Personal loans or budgeting apps exfiltrating or sharing non-financial or personal SMS history of a user."

The [April 10, 2025 policy clarification](https://support.google.com/googleplay/android-developer/answer/15899442) further states: "clearer guidance on restrictions related to financial apps accessing users' SMS history in compliance with our policies."

This means financial apps with an approved SMS exception must ensure:
- SMS data access is limited to **policy-compliant functionality** (financial transactions, budget tracking)
- **Non-financial or personal SMS** content must not be exfiltrated or shared
- All SMS data handling must comply with the [User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311) (Prominent Disclosure, Consent, Privacy Policy)

**Code audit**:
```bash
# Check for broad SMS history queries (review scope — must be financial-only):
grep -rn "Telephony.Sms\|content://sms" --include="*.kt" --include="*.java"

# Check for SMS data sharing with third-party SDKs:
grep -rn "sms.*upload\|sms.*send\|sms.*post\|sms.*api" --include="*.kt" --include="*.java"
```

- [ ] No exfiltration or sharing of non-financial or personal SMS history
- [ ] SMS data access limited to declared financial functionality
- [ ] SMS data handling disclosed in consent + privacy policy + Data Safety

#### 3.1.6 Invalid Use Cases (Will Be Rejected)

The following use cases will NOT be permitted to access SMS and Call Log permissions ([source](https://support.google.com/googleplay/android-developer/answer/10208820)):

- Account verification via SMS (see Alternatives)
- Account verification via phone call (removed July 2026 — use Digital Credentials API or SMS Retriever API)
- Content sharing or invites (see Alternatives)
- Contact prioritization (when not the default handler or System level default contacts handler)
- Social graph and personality profiling
- Call recorder
- Device performance booster
- Device space or data management
- Family or device locator
- Smart or predictive keyboard
- SMS or calls appearing in wallpaper, launcher, and other tools
- SMS translation (when not the default handler)
- Text to voice / speech-voice to text (when not the default handler or an eligible exception)
- SMS and contacts management (when not the default handler or an eligible exception)
- SMS or phone notification enhancement and alerts (when not the default handler or an eligible exception)
- Research (like market research based on SMS)
- Remote control of user phone or other devices
- Any transfer that results in a sale of this data (including SDKs that sell this data)

> **Note**: This list is not exhaustive.

#### 3.1.7 Recommended Alternatives

From the [official alternatives table](https://support.google.com/googleplay/android-developer/answer/10208820):

| Use | Alternative |
|-----|-------------|
| **SMS OTP & account verification** | [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview) — performs SMS-based user verification automatically, without requiring manual code entry and without extra app permissions. If not an option, users can manually enter verification codes. |
| **Account verification via phone call** | ⚠️ **No longer permitted** (July 2026, [source](https://support.google.com/googleplay/android-developer/answer/17134731)). Use [Digital Credentials API](https://developer.android.com/identity/sign-in/credential-manager) or SMS Retriever API instead. |
| **Initiate a text message** | [SMS Intent](https://developer.android.com/guide/components/intents-common#SendMessage) — initiates an SMS or MMS text message via the default handler. |
| **Share content** | [Share Intent](https://developer.android.com/training/sharing/) — enables sharing content or sending invitations through supporting apps without sensitive permissions. |
| **Initiate a phone call** | [Dial Intent](https://developer.android.com/reference/android/content/Intent#ACTION_DIAL) — opens the phone app with a specified number. Does not require `CALL_PHONE` permission. |

#### 3.1.8 Declaration Process

If your app requires SMS/Call Log permissions:
1. Submit **[Permissions Declaration Form](https://support.google.com/googleplay/android-developer/answer/9214102)** in Play Console
2. Select your app's core functionality from the list of supported use cases
3. Provide clear documentation of core functionality
4. If you change the way your app uses these restricted permissions, you must submit the form again with updated information

> **Important**: Deceptive and non-declared uses of permissions may result in a suspension of your app and/or termination of your developer account.

**Code audit**:
```
# HIGH RISK — requires Permissions Declaration Form and exception approval:
grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|RECEIVE_MMS\|RECEIVE_WAP_PUSH\|WRITE_SMS\|READ_CALL_LOG\|WRITE_CALL_LOG\|PROCESS_OUTGOING_CALLS" AndroidManifest.xml

# BLOCKER for loan apps — prohibited by Personal Loans policy:
grep -n "READ_CONTACTS\|WRITE_CONTACTS\|READ_PHONE_NUMBERS" AndroidManifest.xml

# Check for SMS content access in code:
grep -rn "Telephony.Sms\|SmsMessage\|pdus" --include="*.kt"
```

#### 3.1.9 Checklist

- [ ] Verify if SMS/Call Log permissions are truly needed for core functionality (app is "broken" without it)
- [ ] Verify no alternative method exists (e.g., SMS Retriever API for OTP)
- [ ] Permissions Declaration Form submitted with detailed justification
- [ ] App description prominently documents and promotes SMS-dependent core features
- [ ] For old APKs (pre-Jan 2019): exception APKs represent low single-digit % of total install base
- [ ] All SMS/Call Log exceptions comply with Spyware Policy, Permissions Policy, and User Data Policy (Section 3.1.2)
- [ ] No exfiltration of non-financial or personal SMS history (loan/budgeting apps)
- [ ] SMS data not used for advertising, marketing, or improving other apps/services
- [ ] No alternative methods used to derive SMS/Call Log data
- [ ] App stops using permissions immediately upon losing default handler status
- [ ] Personal loan apps: No `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `QUERY_ALL_PACKAGES` in manifest

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

### 3.3 Photo & Video Permissions (Announced Oct 2023, Full Compliance May 2025)

**Policy effective May 28, 2025** (clarified April 15, 2026 — see [Policy announcement](https://support.google.com/googleplay/android-developer/answer/16926792)): Apps with `READ_MEDIA_IMAGES` or `READ_MEDIA_VIDEO` must either:
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

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16926792)): Location access must be core to app functionality and clearly disclosed. Updated April 15, 2026 to introduce the **location button** as the recommended minimum scope for precise location.

**Location button (Android 17+, effective ~May 15, 2026)**: Apps that use precise location for discrete, one-time actions (e.g., "find a store", "tag a photo") should implement the location button by adding the `onlyForLocationButton` flag in the manifest. This replaces the traditional precise-location permission dialog with a single-tap button.

```xml
<uses-permission
    android:name="android.permission.ACCESS_FINE_LOCATION"
    android:onlyForLocationButton="true" />
```

**Persistent precise location**: Apps that require always-on precise location to function must submit a **Play Developer Declaration** in Play Console justifying why the location button or coarse location is insufficient for core features. Pre-review checks in Play Console begin **October 27, 2026**.

**For loan apps**: `ACCESS_FINE_LOCATION` is **entirely prohibited** by the Personal Loans policy regardless of purpose (see Section 3.1.4 and loan-harassment.md). If location is genuinely required for anti-fraud, use `ACCESS_COARSE_LOCATION` only, declare it in Data Safety, and explain the use to users.

**Code audit**:
```bash
# Check for location button flag (required for one-time precise location, Android 17+):
grep -n "onlyForLocationButton" AndroidManifest.xml
grep -n "ACCESS_FINE_LOCATION\|ACCESS_COARSE_LOCATION\|ACCESS_BACKGROUND_LOCATION" AndroidManifest.xml
```

- [ ] `ACCESS_FINE_LOCATION` only if precise location is core functionality (prohibited for loan apps)
- [ ] `ACCESS_COARSE_LOCATION` preferred over fine location when possible
- [ ] One-time precise location uses `onlyForLocationButton` flag (Android 17+)
- [ ] Persistent precise location has an approved Play Developer Declaration
- [ ] No `ACCESS_BACKGROUND_LOCATION` unless absolutely necessary (triggers additional review)
- [ ] Pre-permission dialog explaining why location is needed
- [ ] Graceful degradation when location denied

### 3.5 Camera Permission

- [ ] Camera permission only for documented functionality (KYC photos, document scanning)
- [ ] Pre-permission dialog explaining camera use
- [ ] CameraX used for capture (not deprecated Camera API)

### 3.6 Foreground Service Types (Android 14+ / API 34+)

**Policy**: Apps targeting API 34+ MUST declare a `foregroundServiceType` for each foreground service in the manifest.

**Play Console requirement** ([source](https://support.google.com/googleplay/android-developer/answer/13392821)): For each foreground service type, you must:
1. Describe the use case for each FGS permission used
2. Explain the user impact

Available types: `camera`, `connectedDevice`, `dataSync`, `health`, `location`, `mediaPlayback`, `mediaProjection`, `mediaProcessing`, `microphone`, `phoneCall`, `remoteMessaging`, `shortService`, `specialUse`, `systemExempted`

**Geofencing removed from approved FGS use cases (April 15, 2026, effective ~May 15, 2026)** ([source](https://support.google.com/googleplay/android-developer/answer/16926792)): Geofencing is no longer an approved foreground service use case. Apps must use the [Geofence API](https://developer.android.com/develop/sensors-and-location/location/geofencing) directly instead of running a foreground service. Using FGS for geofencing after the effective date will trigger policy rejection.

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
- [ ] Play Console FGS declaration form completed with use case description and user impact

### 3.7 Exact Alarm Permissions

**Policy**: `USE_EXACT_ALARM` is restricted to alarm/timer/calendar core apps.

**For loan apps**: Not applicable. Loan apps must NOT declare `USE_EXACT_ALARM`. If exact scheduling is genuinely needed, use `SCHEDULE_EXACT_ALARM` with `canScheduleExactAlarms()` check and fallback to inexact alarms.

- [ ] No `USE_EXACT_ALARM` in loan apps

### 3.8 Full-Screen Intent Permission (January 2025)

**Policy**: Starting January 22, 2025, for apps targeting API 34+, `USE_FULL_SCREEN_INTENT` is only auto-granted for calling/alarm apps.

**For loan apps**: Not applicable. Loan apps must NOT declare `USE_FULL_SCREEN_INTENT`. Use high-priority notifications for repayment reminders instead.

- [ ] No `USE_FULL_SCREEN_INTENT` in loan apps

### 3.9 Contacts Permissions (NEW, effective Oct 28, 2026)

**Policy** (announced April 15, 2026, [source](https://support.google.com/googleplay/android-developer/answer/16926792)): Google Play introduced the Contacts Permissions policy to govern **broad access** of users' contacts. Apps that do not need broad access must use the **Android Contact Picker**, a standardized secure picker introduced in Android 17 that grants access only to the specific contacts the user selects.

**Scope**: Apps that target Android 17+ (API level 37+) may only request `READ_CONTACTS` if the Android Contact Picker is insufficient for core functionality. Apps that continue to request broad contacts access without a justified use case will be subject to enforcement, including removal from Google Play.

**Enforcement timeline**:
- **October 27, 2026** — Play Console pre-review checks flag potential contacts permission policy issues
- **October 28, 2026** — Contacts Permissions policy enforcement begins

**For personal loan apps**: `READ_CONTACTS` is **entirely prohibited** by the Personal Loans policy regardless of purpose (see Section 3.1.4). The new Contacts Permissions policy is an **additional enforcement layer** — even switching to Contact Picker does NOT satisfy the Personal Loans policy if contact selection is used for:
- Credit scoring or risk assessment
- Collecting "emergency contacts" for debt collection
- Any form of lending decision or recovery workflow

A loan app using Contact Picker to gather emergency contacts is in **double violation** (Personal Loans policy + Contacts Permissions policy).

**Recommended implementation for apps with legitimate contact sharing**:

```kotlin
// Use Android Contact Picker — user selects specific contacts only, no READ_CONTACTS needed
val pickContact = registerForActivityResult(ActivityResultContracts.PickContact()) { uri ->
    // uri points to the single contact the user chose
}
```

**Play Developer Declaration**: Apps that truly require broad contact access (e.g., messaging apps syncing full address book) must submit a declaration in Play Console justifying why Contact Picker is insufficient. See [Understanding restricted permissions with minimum scope alternatives](https://support.google.com/googleplay/android-developer/answer/16935362).

**Code audit**:
```bash
# Broad contacts permission declared:
grep -n "READ_CONTACTS\|WRITE_CONTACTS" AndroidManifest.xml

# Direct ContactsContract query (indicates broad access rather than Contact Picker):
grep -rn "ContactsContract\.Contacts\.CONTENT_URI\|CommonDataKinds\.Phone\.CONTENT_URI" --include="*.kt" --include="*.java"

# Contact Picker usage (preferred pattern):
grep -rn "ActivityResultContracts\.PickContact\|ACTION_PICK.*Contacts" --include="*.kt" --include="*.java"
```

- [ ] If `READ_CONTACTS` is declared, Contact Picker was evaluated and documented as insufficient
- [ ] Play Developer Declaration submitted for broad contacts access, if required
- [ ] No broad contacts access in personal loan / accessory loan / EWA apps (double violation with Personal Loans policy)
- [ ] Contact Picker used for one-time contact selection use cases
- [ ] Contact data not exfiltrated or transmitted beyond declared use

### 3.10 Permissions Checklist Summary

- [ ] Every permission in manifest has documented business justification
- [ ] Pre-permission rationale dialog shown before runtime permission requests
- [ ] App functions gracefully when ANY permission is denied
- [ ] All Permissions Declaration Forms submitted in Play Console
- [ ] No permissions declared "just in case" — unused permissions removed
