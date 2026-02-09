---
name: play-store
description: Google Play Store submission and compliance checklist for Android apps, with special focus on financial/loan apps. Covers build config, permissions, Data Safety, Financial Features Declaration, Personal Loan policy, sensitive permission restrictions, spyware policy, deceptive behavior, device abuse, consent flow transparency, data transmission audit, loan app harassment policy, account deletion, developer verification, and code-level audit. Updated for 2025-2026 policy cycle.
---

# Google Play Compliance & Launch Checklist

Comprehensive pre-submission audit and compliance verification for Google Play Store publishing. Includes 2025-2026 policy updates with special sections for **financial/loan apps**.

**Policy effective date**: January 28, 2026 (unless otherwise stated per section).

## When to Use

- Preparing an app for first submission or update to Google Play
- Responding to Google Play policy violation notices
- Configuring Play Console (Data Safety, Financial Features Declaration, content rating)
- Auditing code for permission/policy compliance before submission
- Debugging app rejection reasons

## Pre-Submission Audit Process

Evaluate the app against ALL categories below. Output findings as:

```
[GP-XXXXX] status: BLOCKER | WARNING | INFO
  Category: <section number>
  Finding: <what is missing or wrong>
  Evidence: <file:line or manifest entry>
  Fix: <concrete action to resolve>
  Deadline: <policy enforcement date if applicable>
```

Severity definitions:
- **BLOCKER**: App will be rejected or removed. Must fix before submission.
- **WARNING**: May trigger review delay or future enforcement. Fix recommended.
- **INFO**: Best practice improvement. No immediate enforcement risk.

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

---

## 3. Sensitive & Restricted Permissions (CRITICAL)

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

---

## 4. Financial Features Declaration (Mandatory for ALL Apps)

### 4.1 Requirement

**ALL apps** on Google Play must complete the Financial Features Declaration in Play Console, even apps without financial features. As of October 30, 2025, **updates cannot be published** until this declaration is completed.

**Path**: Play Console > App content > Financial features declaration

### 4.2 What to Declare

- Whether app contains or promotes financial products/services
- Types of financial features (personal loans, banking, insurance, cryptocurrency, etc.)
- Licensing documentation for applicable countries
- Lender relationships and business model

### 4.3 Personal Loan App Requirements

If your app includes personal loan features (direct lending, loan facilitation, line of credit, EWA):

**Metadata disclosure (in app description)**:
- [ ] Minimum and maximum repayment period
- [ ] Maximum Annual Percentage Rate (APR)
- [ ] Representative example of total loan cost (principal + all fees)
- [ ] Comprehensive privacy policy link

**Documentation upload**:
- [ ] Proof of valid license from relevant authority in each target country
- [ ] Lender information and business relationship
- [ ] Google must be able to verify connection between developer account and licenses

**Prohibitions**:
- [ ] No short-term loans (< 60 days repayment) — only Pakistan has limited exception
- [ ] No access to photos, contacts for risk assessment (explicitly prohibited permissions: `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`)
- [ ] SMS data must NOT be used for credit scoring or lending decisions (see Section 3.1 for full SMS policy details)
- [ ] No predatory lending practices (excessive fees, harassment)
- [ ] App category MUST be set to "Finance"

### 4.4 Country-Specific Requirements

| Country | Requirement | Deadline |
|---------|------------|---------|
| India | Must be on RBI "Digital Lending Apps" list | Oct 30, 2025 |
| Thailand | Display loan service provider, max interest rates, all fees | Mar 4, 2026 |
| Philippines | SEC Registration + Certificate of Authority | Active |
| Nigeria | FCCPC approval letter | Active |
| Pakistan | Only country allowing < 60 day loans (with restrictions) | Active |
| Colombia | Must comply with local financial regulations + global policy | Active |

### 4.5 Line of Credit Apps (April 2025 Update)

As of May 28, 2025, apps providing lines of credit are subject to the same requirements as personal loan apps:
- Disclosure of repayment terms, APR, representative cost
- Prohibition on accessing photos, contacts, location for risk assessment (see Section 3.1 for SMS-specific rules)
- Comprehensive privacy policy

### 4.6 Checklist

- [ ] Financial Features Declaration completed in Play Console
- [ ] App category set to "Finance" (if loan/credit app)
- [ ] All licensing documents uploaded for target countries
- [ ] Loan terms displayed in app description
- [ ] No short-term loans (< 60 days)
- [ ] No access to restricted data (photos, contacts) for lending decisions — SMS governed by separate policy (Section 3.1)

---

## 5. Data Safety Section (Mandatory)

### 5.1 When Required

ALL apps on Google Play, including those that collect NO data.
Required for: closed testing, open testing, and production tracks.
Only exempted: internal testing track.

### 5.2 What to Declare

For EVERY piece of data your app or ANY SDK collects:

| Data Category | Examples |
|--------------|---------|
| Location | Approximate, precise |
| Personal info | Name, email, user ID, address, phone |
| Financial info | Payment info, purchase history, credit info |
| Health & fitness | Health data, fitness data |
| Messages | Emails, SMS, other messages |
| Photos & videos | Photos, videos |
| Audio | Voice recordings, music files |
| Files & docs | Files, documents |
| Calendar | Calendar events |
| Contacts | Contacts |
| App activity | Page views, in-app search, installed apps |
| Web browsing | Web history |
| App info & performance | Crash logs, diagnostics, performance data |
| Device or other IDs | Device ID, advertising ID, GAID |

### 5.3 For Each Data Type, Declare

1. **Is it collected?** (transmitted off device)
2. **Is it shared?** (transferred to third parties)
3. **Is it required or optional?**
4. **Purpose**: App functionality, analytics, developer communications, advertising, fraud prevention, security, compliance, personalization, account management
5. **Is it encrypted in transit?**
6. **Can users request deletion?**

### 5.4 SDK Audit (Critical)

YOU are responsible for ALL data collected by third-party SDKs. Google uses ML to cross-check — inconsistencies trigger review.

For each SDK:
1. Check SDK documentation for data collection practices
2. Verify with SDK's own Data Safety guidance (most major SDKs publish this)
3. Include SDK's data collection in YOUR Data Safety form
4. Update whenever SDK version changes

Common SDKs and their data collection:

| SDK | Data Collected |
|-----|---------------|
| Firebase Analytics | Device ID, app activity, diagnostics |
| Firebase Crashlytics | Crash logs, device info, stack traces |
| Firebase Messaging | Push tokens, device ID |
| Firebase Performance | Performance metrics, device info |
| AdMob/Google Ads | Advertising ID, location, app activity |
| Facebook SDK | Device ID, app activity, advertising data |
| AppsFlyer | Device ID, attribution data, app activity |
| Adjust | Device ID, attribution data |
| Google Play Services (Ads ID) | Advertising identifier |

**Code audit for SDK data collection**:
```
# Find all SDKs in build.gradle:
grep -n "implementation\|api(" build.gradle* build-script/*.gradle

# Check for device ID collection:
grep -rn "ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId" --include="*.kt"

# Check for contact/SMS/call log access:
grep -rn "ContactsContract\|Telephony.Sms\|CallLog" --include="*.kt"
```

### 5.5 Data Deletion Questions (Mandatory)

You MUST answer data deletion questions in the Data Safety form:
- Can users request data deletion?
- What data is deleted vs. retained?
- Retention justification for data not deleted

### 5.6 Checklist

- [ ] Data Safety form completed in Play Console
- [ ] ALL SDKs audited for data collection (see table above)
- [ ] Collection matches actual app behavior (Google ML verifies this)
- [ ] Data handling matches privacy policy text
- [ ] Encryption in transit declared accurately
- [ ] Data deletion mechanism declared
- [ ] Updated whenever SDK or data practices change
- [ ] Account deletion data questions answered

---

## 6. Account Deletion Requirement (Mandatory)

### 6.1 Policy

If your app allows users to create an account, you MUST:
1. Allow users to **delete their account** from within the app
2. Provide a **web link** where users can request account and data deletion (for users who already uninstalled)
3. **Delete associated user data** when account is deleted

### 6.2 What Must Be Deleted

All user data associated with the account:
- Personal and sensitive user data
- Personally identifiable information
- Financial and payment information
- Authentication information
- Phonebook, contacts, location data
- SMS and call-related data
- Any other data linked to the account

### 6.3 Exceptions

You may retain data for legitimate reasons:
- Security and fraud prevention
- Regulatory compliance (financial record retention)
- BUT must clearly disclose retention in privacy policy

### 6.4 What Does NOT Qualify

- Account deactivation, disabling, or "freezing" does NOT count as deletion
- Must be permanent, actual deletion

### 6.5 Play Console Requirements

- [ ] Account deletion available in-app
- [ ] Web link for account deletion provided in Play Console
- [ ] Web link is publicly accessible and functional
- [ ] Data deletion questions answered in Data Safety form
- [ ] Privacy policy documents data retention policy

**Code audit**:
```
# Check for account deletion functionality:
grep -rn "delete.*account\|account.*delet\|remove.*account" --include="*.kt" -i
grep -rn "deleteAccount\|removeAccount\|accountDeletion" --include="*.kt"
```

---

## 7. Privacy Policy (Mandatory)

### 7.1 Requirements

- [ ] Hosted on active, publicly accessible URL (NOT PDF, NOT geofenced)
- [ ] URL provided in Play Console designated field
- [ ] Link accessible within the app itself
- [ ] Entity name matches Play Console developer name
- [ ] Privacy contact info included
- [ ] Available in all languages the app supports

### 7.2 Content Must Include

- [ ] What personal/sensitive data is collected
- [ ] How data is used (purposes for each data type)
- [ ] How data is shared (and with whom — name third parties)
- [ ] Data retention period
- [ ] Data deletion procedure (how users can request deletion)
- [ ] Security measures for data protection
- [ ] Third-party SDK data practices (each SDK listed)
- [ ] Children's data handling (if applicable)
- [ ] Contact information for privacy inquiries
- [ ] Date of last update

### 7.3 Financial App Privacy Policy Additions

For loan/financial apps, the privacy policy must ALSO include:
- [ ] Types of financial data collected
- [ ] How credit decisions are made
- [ ] Data sharing with credit bureaus or financial partners
- [ ] Loan terms and conditions reference
- [ ] Regulatory compliance statements for target countries

### 7.4 Anti-Patterns

- NEVER use a generic/template policy without customization
- NEVER host policy on a domain you don't control
- NEVER let the policy URL return 404
- NEVER omit SDK data collection from the policy
- NEVER have policy content contradict Data Safety declarations

---

## 8. Store Listing

### 8.1 Required Assets

| Asset | Specification |
|-------|--------------|
| App icon | 512x512 PNG, 32-bit, no alpha |
| Feature graphic | 1024x500 PNG or JPEG |
| Screenshots | Min 2, max 8 per device type. Min 320px, max 3840px |
| Phone screenshots | Required. 16:9 or 9:16 recommended |
| Tablet screenshots | Required if app supports tablets |
| Short description | Max 80 characters |
| Full description | Max 4000 characters |

### 8.2 Listing Quality

- [ ] Title: accurate, no keyword stuffing (max 30 chars)
- [ ] Short description: clear value proposition
- [ ] Full description: features and functionality, not marketing fluff
- [ ] Screenshots: actual app UI (not mockups with misleading content)
- [ ] No misleading claims about functionality
- [ ] No references to other platforms ("also on iOS")
- [ ] No excessive capitalization or emoji spam
- [ ] Contact email is valid and monitored

### 8.3 Financial App Listing Requirements

For personal loan apps, the description MUST include:
- [ ] Minimum and maximum repayment period
- [ ] Maximum APR (Annual Percentage Rate)
- [ ] Representative cost example (principal + all fees)
- [ ] Loan service provider name
- [ ] Licensing information for applicable countries

### 8.4 Metadata Anti-Patterns (Rejection Triggers)

- NEVER use "best", "number 1", "#1" without third-party verification
- NEVER reference competitor app names
- NEVER include call-to-action in icon ("FREE", "SALE")
- NEVER show content in screenshots that differs from actual app
- NEVER use misleading app category
- NEVER include promotional pricing that isn't currently active

---

## 9. Content Rating (Mandatory)

### 9.1 Process

1. Complete IARC (International Age Rating Coalition) questionnaire in Play Console
2. Answer questions about: violence, sexual content, language, controlled substances, user interaction, data sharing, location sharing, in-app purchases
3. Receive automatic ratings for multiple regions (ESRB, PEGI, etc.)

### 9.2 Rules

- [ ] Content rating questionnaire completed
- [ ] Rating matches actual app content
- [ ] Re-submit questionnaire if app content changes significantly
- [ ] Apps without rating will be removed from Google Play

### 9.3 Age-Restricted Content (2026 Update)

Starting January 1, 2026:
- Apps with matchmaking, dating, real money gambling, or games/contests must use Play Console features to block minors
- Data from Age Signals API may only be used for age-appropriate experiences
- U.S. state age verification laws (Utah May 2026, Louisiana July 2026) may require additional compliance

---

## 10. Deceptive Behavior Policy (Top Rejection Reason)

Google Play's Deceptive Behavior policy is the **#1 cause of app rejection**. This section requires deep code-level audit beyond simple checklist items.

### 10.1 Misleading Claims & Metadata Mismatch

- [ ] App description precisely matches actual functionality — no exaggeration
- [ ] Screenshots show real app UI, not misleading mockups
- [ ] No claims of features that don't exist or require undisclosed conditions
- [ ] App category correctly reflects primary functionality
- [ ] No keyword stuffing in title or description

### 10.2 System UI Mimicry

Apps must NEVER create UI that mimics Android system dialogs, notifications, or warnings.

**Code audit**:
```bash
# Check for dialogs that might mimic system warnings:
grep -rn "AlertDialog\|MaterialAlertDialog" --include="*.kt" app/src/main/

# Check for strings containing system-like urgency language:
grep -rn "warning\|alert\|system\|update.*required\|security.*risk" --include="*.xml" app/src/main/res/values/
```

- [ ] No AlertDialogs styled to look like system warnings
- [ ] No notifications that mimic system notifications
- [ ] No fake "virus detected" or "system update required" messages
- [ ] No UI elements that look like Android system settings

### 10.3 Undisclosed Data Collection

This is the intersection of Deceptive Behavior and Spyware policies. An app is deceptive if it collects data that users would not reasonably expect based on its description and disclosures.

**Code audit**:
```bash
# Check if data collection starts before consent dialog:
grep -rn "onCreate\|initializeModules\|init(" --include="*.kt" app/src/main/ | grep -i "application\|app\.kt"

# Check for SDK initialization before consent:
grep -rn "AppsFlyerLib\|FirebaseApp\|Facebook\|Adjust\|MixPanel" --include="*.kt" app/src/main/ | grep -i "init\|start\|configure"

# Check startup sequence — is consent shown before data collection?
grep -rn "showComplianceWindow\|showConsentDialog\|showDisclosure" --include="*.kt"
```

**Critical check**: Compare the order of operations at app startup:
1. What SDKs are initialized in `Application.onCreate()`?
2. When is the consent/compliance dialog shown?
3. Does any data leave the device BEFORE the user sees the consent dialog?

If SDKs initialize and transmit data before consent → **BLOCKER**

- [ ] NO third-party SDKs initialized before user consent
- [ ] NO data transmitted before consent dialog is shown AND accepted
- [ ] Consent dialog appears on FIRST app launch, not buried in settings
- [ ] Actual data collection matches what consent dialog describes

### 10.4 Disclosure-vs-Reality Gap

Google's AI review system cross-checks what the app **claims** to collect (in Data Safety / privacy policy / consent dialogs) against what the APK **actually does** (via static analysis of code, permissions, SDK fingerprints).

**Audit process**: For each data type collected in code, verify it is disclosed in ALL THREE places:
1. In-app consent/disclosure dialog
2. Privacy policy
3. Data Safety form

| Data Type | Code Location | Disclosed in Consent? | In Privacy Policy? | In Data Safety? |
|-----------|--------------|----------------------|-------------------|-----------------|
| SMS content | `Telephony.Sms.CONTENT_URI` | ? | ? | ? |
| Installed apps | `getInstalledPackages/Applications` | ? | ? | ? |
| Device fingerprint | `Build.FINGERPRINT`, `MediaDrm` | ? | ? | ? |
| Location | `LocationManager`, `FusedLocation` | ? | ? | ? |
| IP address | Network socket / WiFi info | ? | ? | ? |
| Advertising ID | `getAdvertisingIdInfo` | ? | ? | ? |
| Screen info | `DisplayMetrics`, refresh rate | ? | ? | ? |
| Memory/storage | `Runtime.getRuntime()`, `StatFs` | ? | ? | ? |
| NFC status | `NfcManager` | ? | ? | ? |
| Battery level | `BatteryManager` | ? | ? | ? |
| Sensor data | `SensorManager` | ? | ? | ? |

Fill this table for EVERY data type found in the codebase. Any row where a "?" is "No" → potential **BLOCKER**.

- [ ] Every data type collected in code is disclosed in consent dialog
- [ ] Every data type collected in code is in privacy policy
- [ ] Every data type collected in code is in Data Safety form
- [ ] No SDK collects data not disclosed in all three places

### 10.5 Hidden Functionality

Apps must not contain functionality that is not disclosed to users or that changes behavior based on conditions not visible to users.

**Code audit**:
```bash
# Remote code execution (CRITICAL — immediate rejection):
grep -rn "DexClassLoader\|PathClassLoader\|InMemoryDexClassLoader" --include="*.kt"
grep -rn "Runtime.getRuntime().exec\|ProcessBuilder" --include="*.kt"
grep -rn "System.loadLibrary\|System.load(" --include="*.kt" | grep -v "native"

# Dynamic feature loading from server:
grep -rn "Class.forName\|classLoader\|loadClass" --include="*.kt"

# Behavior change based on server flags (not inherently bad, but must be disclosed):
grep -rn "feature.*flag\|remote.*config\|A/B.*test\|experiment" --include="*.kt" -i

# Check if app behavior changes based on user's loan status or region:
grep -rn "isOverdue\|isDefaulted\|loanStatus.*==\|delinquent" --include="*.kt" -i
```

- [ ] No DexClassLoader or dynamic class loading from server
- [ ] No native library loading from URLs
- [ ] No undisclosed remote configuration that changes core behavior
- [ ] No behavior differences based on user's loan/debt status that aren't disclosed

### 10.6 Permissions Policy

- [ ] Request ONLY permissions necessary for core functionality
- [ ] Pre-permission rationale dialog before each runtime request
- [ ] App functions gracefully when permissions denied
- [ ] NO sensitive permissions (location/contacts/SMS) for non-core use
- [ ] All Permissions Declaration Forms submitted in Play Console
- [ ] Foreground service permissions declared and justified with video demo

### 10.7 Ads Compliance (if applicable)

- [ ] No ads mimicking app UI or system notifications
- [ ] No fullscreen interstitial ads that can't be closed within 2 seconds
- [ ] No ads triggered by accidental taps (misleading close buttons)
- [ ] Ad SDKs declared in Data Safety section
- [ ] No personalized ads for children under 12 (Families Policy)
- [ ] Ad frequency reasonable (not overwhelming)

### 10.8 Families Policy (if targeting children)

- [ ] Child Safety Standards self-certification completed
- [ ] No personalized advertising
- [ ] Age-appropriate content only
- [ ] Parental consent mechanisms implemented
- [ ] No data collection from children beyond minimum required

### 10.9 User-Generated Content (if applicable)

- [ ] Content moderation system in place
- [ ] Reporting mechanism for objectionable content
- [ ] Terms of service prohibit illegal/policy-violating content
- [ ] In-app blocking functionality

---

## 11. Spyware & User Data Policy (CRITICAL)

Google Play's Spyware Policy defines four categories of prohibited behavior. **Financial/loan apps are under heightened scrutiny** because they handle sensitive financial data and historically have the highest violation rates.

**Policy reference**: [Google Play Spyware Policy](https://support.google.com/googleplay/android-developer/answer/10144311)

### 11.1 Category 1: Data Collection Without Adequate Notice

**Definition**: Collecting personal or sensitive data without a clear, prominent disclosure that meets ALL of these requirements:

1. Disclosure must be **inside the app** (not just in privacy policy or Play Store listing)
2. Disclosure must appear **before** data collection begins
3. Must describe **what data** is collected and **how** it is used
4. Must require **affirmative user action** (tap "I agree", not just "Continue")
5. Must NOT be buried in Terms of Service or privacy policy alone

**Code audit — Consent flow validation**:
```bash
# Find the consent/compliance dialog:
grep -rn "ComplianceWindow\|ConsentDialog\|DisclosureDialog\|PromptDialog" --include="*.kt"
grep -rn "showComplianceWindow\|showConsentDialog\|showDisclosure" --include="*.kt"

# Check what happens when user DECLINES:
# Look for both ok/confirm and cancel/refuse listeners — are they different?
grep -rn "okListener\|confirmListener\|agreeListener" --include="*.kt" -A 3
grep -rn "refuseListener\|cancelListener\|declineListener" --include="*.kt" -A 3

# Check dialog layout for consent checkbox:
grep -rn "CheckBox\|checkbox\|check_box" --include="*.xml" app/src/main/res/layout/dialog*

# Verify disclosure text content:
grep -rn "one_text_warrant\|consent_text\|disclosure_text\|privacy_notice" --include="*.xml" app/src/main/res/values/
```

**Critical validation points**:
- **Decline must work**: If "Cancel" and "OK" execute the same code path → **BLOCKER**
- **Decline must have consequences**: User who declines MUST NOT have their data collected silently
- **Checkbox consent**: For sensitive data (SMS, location, apps), Google recommends explicit checkbox, not just "Continue" button
- **Granular consent**: Ideally users can consent to some data types and decline others

- [ ] Prominent disclosure shown BEFORE any data collection starts
- [ ] Disclosure clearly lists ALL data types collected (SMS, apps, location, device info, etc.)
- [ ] Disclosure explains PURPOSE for each data type
- [ ] User must take AFFIRMATIVE action (not pre-checked, not "Continue")
- [ ] "Decline" button genuinely prevents data collection
- [ ] User can still use basic app functionality after declining (graceful degradation)
- [ ] Disclosure is NOT buried in ToS/privacy policy — it's a standalone prominent dialog

### 11.2 Category 2: Covert Data Transmission

**Definition**: Transmitting personal or sensitive data off-device without the user's knowledge, including:
- Sending data before showing consent
- Sending data types not mentioned in consent
- Sending data to undisclosed third parties
- Sending data when app is in background without notification

**Code audit — Data transmission timing**:
```bash
# Check Application.onCreate() for early SDK initialization:
grep -rn "class.*Application" --include="*.kt" -l
# Then read each Application class for SDK init calls

# Check if analytics/attribution SDKs start before consent:
grep -rn "AppsFlyerLib.*init\|AppsFlyerLib.*start" --include="*.kt"
grep -rn "FirebaseApp.initializeApp\|Firebase.initialize" --include="*.kt"
grep -rn "FacebookSdk.sdkInitialize\|FacebookSdk.fullyInitialize" --include="*.kt"
grep -rn "Adjust.onCreate\|Adjust.initSdk" --include="*.kt"

# Check for background data transmission:
grep -rn "WorkManager\|PeriodicWorkRequest\|OneTimeWorkRequest" --include="*.kt"
grep -rn "AlarmManager\|JobScheduler\|JobService" --include="*.kt"
grep -rn "BroadcastReceiver.*BOOT_COMPLETED" --include="*.kt" --include="*.xml"

# Check for data upload endpoints:
grep -rn "uploadInfo\|uploadData\|sendData\|postData\|submitData" --include="*.kt"
# Then trace each upload function to see WHEN it is called
```

**Trace every data upload path**:
For each upload endpoint found, trace backwards to answer:
1. **When** is this called? (app start? user action? timer? background?)
2. **What** data does it send? (trace the request body construction)
3. **Is the user aware** this is happening at this moment?
4. **To where** is data sent? (first-party server? third-party?)

- [ ] NO SDK data transmission before user consent
- [ ] NO background data uploads without user-visible notification
- [ ] NO data sent to undisclosed third-party servers
- [ ] ALL upload endpoints traced and documented
- [ ] User sees loading indicator or progress during data upload (transparency)
- [ ] Data upload only occurs during user-initiated actions, not silently

### 11.3 Category 3: Data Collection Unrelated to App Functionality

**Definition**: Collecting data that has no reasonable connection to the app's stated purpose.

**For financial/loan apps**, the following MAY be justified (with proper disclosure):
- Financial SMS (for transaction verification)
- Location (for fraud detection)
- Device ID (for device binding)
- Camera (for KYC document capture)

**For financial/loan apps**, the following are HARD TO JUSTIFY:
- Complete installed app inventory (especially entertainment, dating, social apps)
- Hardware fingerprinting (bootloader, radio version, board, ROM tags)
- IP addresses (IPv4/IPv6)
- NFC capability detection
- Screen refresh rate
- Memory/storage usage details
- Device uptime metrics

**Code audit — Data minimization**:
```bash
# Identify ALL data points collected and sent to server:
# 1. Find the main params/payload construction:
grep -rn "addProperty\|put(\|putExtra\|JsonObject\|JSONObject" --include="*.kt" | grep -i "param\|payload\|body\|request"

# 2. Check for excessive device info collection:
grep -rn "Build\.\(FINGERPRINT\|BOOTLOADER\|BOARD\|HARDWARE\|HOST\|TAGS\|RADIO\)" --include="*.kt"
grep -rn "SystemClock\.\(elapsedRealtime\|uptimeMillis\)" --include="*.kt"
grep -rn "NfcManager\|NfcAdapter" --include="*.kt"
grep -rn "DisplayMetrics\|refreshRate\|densityDpi" --include="*.kt"
grep -rn "Runtime.*maxMemory\|Runtime.*totalMemory\|Runtime.*freeMemory" --include="*.kt"
grep -rn "StatFs\|totalBytes\|freeBytes\|availableBytes" --include="*.kt"
grep -rn "WifiManager.*connectionInfo\|getIpAddress\|InetAddress" --include="*.kt"

# 3. Check for installed apps enumeration:
grep -rn "getInstalledPackages\|getInstalledApplications\|queryIntentActivities" --include="*.kt"
grep -rn "PackageManager.*GET_" --include="*.kt"

# 4. Count total data points per API request:
# Find the base params class and count fields
```

**Data minimization test**: For each collected data point, ask:
1. Is this data **necessary** for the app's stated core function?
2. Could the app function **without** this data?
3. Is there a **less invasive** alternative?

If the answer to #1 is "No" → the data point should be removed or justified with very strong disclosure.

- [ ] Every collected data point has documented business justification
- [ ] No collection of hardware fingerprinting data beyond basic device model/OS
- [ ] Installed app enumeration limited to documented interoperability needs (or removed)
- [ ] IP address collection justified and disclosed
- [ ] Memory/storage data collection justified and disclosed
- [ ] Device uptime/boot time collection justified and disclosed

### 11.4 Category 4: Personal SMS/Call Log Exfiltration (CRITICAL for Loan Apps)

**Policy (verbatim)**:
> "Personal loans or budgeting apps may **not exfiltrate or share non-financial or personal SMS history** of a user."

This means even if your app has a valid SMS exception (Section 3.1), you MUST:
1. Filter SMS to ONLY financial/transactional messages BEFORE upload
2. NEVER upload personal SMS content
3. NEVER use SMS data for credit scoring or lending decisions
4. NEVER share SMS data with third parties

**Code audit — SMS exfiltration check**:
```bash
# Find ALL SMS query code:
grep -rn "Telephony.Sms\|content://sms\|SmsMessage" --include="*.kt"

# Check what SMS fields are read:
grep -rn "Telephony.Sms\.\(BODY\|ADDRESS\|DATE\|READ\|STATUS\|TYPE\)" --include="*.kt"

# Check SMS filtering logic — is it BEFORE or AFTER query?
# If filtering happens in SQL WHERE clause → better (less data loaded)
# If filtering happens in code after query → all SMS is read first (worse)
grep -rn "LIKE\|like\|contains\|matches\|filter" --include="*.kt" | grep -i "sms\|message\|body"

# Check what is uploaded — does the request include SMS body text?
grep -rn "SP_BODY\|sms_body\|message_body\|body" --include="*.kt" | grep -i "add\|put\|property"

# Check for incremental/continuous SMS collection:
grep -rn "SMS_SUCCESS_TIME\|last.*sms.*time\|sms.*timestamp" --include="*.kt"
```

**SMS filtering adequacy test**:
- Are filter patterns specific enough? (`%bank%` is too broad, matches personal messages about banks)
- Does filtering happen at the SQL query level? (better) or in-memory? (worse — all SMS loaded into memory)
- Is SMS body content uploaded, or only metadata (sender, timestamp)?
- Is there a mechanism to exclude personal sender numbers (contacts, known personal numbers)?

- [ ] SMS filtering occurs in SQL WHERE clause (not post-query)
- [ ] Filter patterns are specific to financial institutions (5-digit short codes, known bank sender IDs)
- [ ] SMS body content is NOT uploaded to server (only metadata if needed)
- [ ] If SMS body IS needed: strict regex filtering removes personal content BEFORE upload
- [ ] No incremental/continuous SMS harvesting (one-time collection at specific user action only)
- [ ] SMS data is NOT used for credit scoring or lending decisions
- [ ] SMS data is NOT shared with third-party analytics or advertising services

### 11.5 Spyware Policy Checklist

- [ ] Prominent disclosure shown before ALL data collection (Category 1)
- [ ] User can decline and still use basic functionality (Category 1)
- [ ] No data transmitted before consent (Category 2)
- [ ] No background data uploads without notification (Category 2)
- [ ] All collected data is necessary for stated functionality (Category 3)
- [ ] No personal SMS content exfiltration (Category 4)
- [ ] Data collection stops when user revokes permissions
- [ ] Data deletion mechanism exists and works

---

## 12. Device and Network Abuse

### 12.1 Device Settings Modification

Apps must NEVER modify device settings without explicit user consent and clear disclosure.

**Code audit**:
```bash
# Check for device settings writes:
grep -rn "Settings.System\|Settings.Secure\|Settings.Global" --include="*.kt" | grep -i "put\|write\|set"

# Check for WiFi/Bluetooth manipulation:
grep -rn "WifiManager.*setWifiEnabled\|BluetoothAdapter.*enable\|BluetoothAdapter.*disable" --include="*.kt"

# Check for volume/brightness changes:
grep -rn "AudioManager.*setStreamVolume\|SCREEN_BRIGHTNESS" --include="*.kt"

# Check for device admin capabilities:
grep -rn "DeviceAdminReceiver\|DevicePolicyManager" --include="*.kt" --include="*.xml"
grep -rn "BIND_DEVICE_ADMIN\|device_admin" --include="*.xml"
```

- [ ] No modification of system settings without explicit user action
- [ ] No DeviceAdminReceiver declared (unless core functionality requires it)
- [ ] No WiFi/Bluetooth state changes
- [ ] No volume/brightness manipulation

### 12.2 Accessibility Service Abuse

Accessibility services are heavily scrutinized. Using them for non-accessibility purposes is a **BLOCKER**.

**Code audit**:
```bash
# Check for accessibility service declaration:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt"
grep -rn "accessibilityservice" --include="*.xml" app/src/main/

# Check for accessibility API usage:
grep -rn "AccessibilityEvent\|AccessibilityNodeInfo\|performAction" --include="*.kt"
```

- [ ] No AccessibilityService unless core functionality requires it
- [ ] No using accessibility APIs for automated UI interaction
- [ ] No using accessibility to scrape content from other apps
- [ ] If AccessibilityService is used: Permissions Declaration Form submitted with video demo

### 12.3 App Interference

Apps must not interfere with other apps or the operating system.

**Code audit**:
```bash
# Check for overlay permissions/usage:
grep -rn "SYSTEM_ALERT_WINDOW\|TYPE_APPLICATION_OVERLAY\|TYPE_SYSTEM_ALERT" --include="*.kt" --include="*.xml"

# Check for task/process manipulation:
grep -rn "ActivityManager.*killBackgroundProcesses\|forceStopPackage" --include="*.kt"

# Check for preventing uninstallation:
grep -rn "ACTION_UNINSTALL\|DELETE_PACKAGES\|PREVENT_UNINSTALL" --include="*.kt" --include="*.xml"
```

- [ ] No SYSTEM_ALERT_WINDOW for non-essential overlay functionality
- [ ] No killing other apps' background processes
- [ ] No mechanism to prevent or complicate app uninstallation

### 12.4 Network Abuse

**Code audit**:
```bash
# Check for proxy/VPN functionality:
grep -rn "VpnService\|BIND_VPN_SERVICE" --include="*.kt" --include="*.xml"

# Check for excessive network requests:
grep -rn "PeriodicWorkRequest\|repeatInterval\|setInitialDelay" --include="*.kt"
```

- [ ] No VPN/proxy functionality unless core to app purpose
- [ ] No excessive background network polling
- [ ] No mining cryptocurrency in background

### 12.5 Device Abuse Checklist

- [ ] No device settings modification
- [ ] No accessibility service abuse
- [ ] No app interference
- [ ] No network abuse
- [ ] No preventing uninstallation
- [ ] No root detection that blocks entire app (detecting root for security and warning user is acceptable; blocking app entirely may be flagged)

---

## 13. Consent Flow & Data Transparency Audit

This section provides a structured audit of the entire consent and data transparency flow. It goes beyond individual policy checks to evaluate the **end-to-end user experience** of data collection.

### 13.1 Consent Flow Sequence Audit

**Trace the complete app startup and data collection sequence**:

```
Step 1: App starts (Application.onCreate)
  → What SDKs initialize here?
  → Does any data leave the device at this point?

Step 2: Splash screen / loading screen
  → Is any data collected during splash?
  → How long is the splash? Does it hide data collection?

Step 3: Consent/compliance dialog
  → What does the dialog say?
  → What are the button options?
  → What happens for each button choice?
  → Is there a checkbox or just buttons?

Step 4: Permission requests
  → What permissions are requested?
  → In what order?
  → What happens when each is denied?

Step 5: First user action that triggers data upload
  → What triggers the upload?
  → What data is in the upload payload?
  → Is the user aware of the upload?
```

**Code audit**:
```bash
# Map the startup sequence:
grep -rn "class.*Application.*:" --include="*.kt" -l
# Read Application class for initialization order

# Map consent dialog trigger:
grep -rn "showComplianceWindow\|showConsentDialog\|showDisclosure\|showPermissionDialog" --include="*.kt"

# Map permission request triggers:
grep -rn "requestPermissions\|ActivityCompat.requestPermissions\|registerForActivityResult" --include="*.kt"

# Map data upload triggers:
grep -rn "uploadInfo\|uploadData\|uploadDeviceInfo\|uploadBigData" --include="*.kt"
# For each, trace the call chain back to a user action or automatic trigger
```

- [ ] Consent dialog shown before ANY data collection or SDK initialization
- [ ] Each permission has a pre-request rationale dialog explaining WHY it's needed
- [ ] User action (not automatic timer) triggers data uploads
- [ ] Loading indicator visible during data upload
- [ ] Clear separation between "data needed for app to work" vs "optional data"

### 13.2 Permission Denial Handling

For each runtime permission, verify what happens when the user DENIES it:

| Permission | Denied Behavior | Acceptable? |
|-----------|----------------|-------------|
| READ_SMS | ? | Must still allow loan application |
| CAMERA | ? | May block KYC step (acceptable with explanation) |
| ACCESS_COARSE_LOCATION | ? | Must still allow basic functionality |

**Code audit**:
```bash
# Check permission denial handling:
grep -rn "onRequestPermissionsResult\|PERMISSION_DENIED\|shouldShowRequestPermissionRationale" --include="*.kt"

# Check if app crashes or becomes unusable when permissions denied:
grep -rn "finish()\|exitProcess\|System.exit" --include="*.kt" | grep -v "test"
```

- [ ] App does NOT crash when any permission is denied
- [ ] App does NOT call `finish()` or `System.exit()` when permission denied
- [ ] App provides alternative flow when sensitive permissions denied
- [ ] No repeated permission request loops (max 2 requests, then explain in settings)

### 13.3 Prominent Disclosure Content Requirements

The prominent disclosure (consent dialog) must meet ALL of these Google requirements:

1. **Standalone**: Not embedded in ToS or privacy policy
2. **Before collection**: Shown before data leaves the device
3. **Clear language**: Plain language, not legal jargon
4. **Specific**: Lists each data type (not just "device information")
5. **Purpose stated**: Explains why each data type is needed
6. **Affirmative action**: User must actively agree (not pre-checked)
7. **Declinable**: User can decline and still use basic functionality

**Content audit** — verify the consent dialog text includes:

- [ ] "We collect SMS messages" (if applicable) — not just "device information"
- [ ] "We collect list of installed apps" (if applicable)
- [ ] "We collect your location" (if applicable)
- [ ] "We collect device identifiers" (if applicable)
- [ ] Purpose for each: "for fraud prevention" / "for identity verification" / etc.
- [ ] "Data is encrypted and sent to [server URL]"
- [ ] "Data is also shared with [third parties]" (if applicable)
- [ ] Link to full privacy policy
- [ ] "You can decline and still use [basic features]"

### 13.4 Third-Party Data Sharing Transparency

For each third-party that receives user data, verify disclosure:

| Third Party | Data Received | Disclosed in Consent? | In Privacy Policy? | In Data Safety? |
|-------------|-------------|----------------------|-------------------|-----------------|
| AppsFlyer | Device ID, attribution, app events | ? | ? | ? |
| Firebase | Crash data, analytics events | ? | ? | ? |
| Credit bureaus | Personal info, credit data | ? | ? | ? |
| Debt collection agencies | Contact info, loan status | ? | ? | ? |

- [ ] ALL third-party data recipients named in privacy policy
- [ ] Data shared with third parties is declared in Data Safety form
- [ ] Consent dialog mentions third-party sharing (at minimum: "shared with our partners")

---

## 14. Loan App Harassment & Predatory Lending (Financial Apps Only)

Google Play has specific policies targeting predatory lending and aggressive debt collection practices, particularly in emerging markets.

### 14.1 Prohibited Contact/Harassment Practices

**Policy**: Loan apps must NOT:
- Access user's contact list for debt collection
- Send automated messages to user's contacts about overdue loans
- Call/message user's emergency contacts for debt collection
- Use aggressive notification patterns to pressure repayment
- Threaten users with exposure or public shaming

**Code audit**:
```bash
# Check for contact list access for collection:
grep -rn "ContactsContract\|READ_CONTACTS\|WRITE_CONTACTS" --include="*.kt"

# Check for automated SMS sending:
grep -rn "SmsManager\|sendTextMessage\|sendMultipartTextMessage" --include="*.kt"

# Check for automated calling:
grep -rn "ACTION_CALL\|ACTION_DIAL\|TelecomManager" --include="*.kt" | grep -v "intent.*filter"

# Check for aggressive notification patterns:
grep -rn "NotificationManager\|NotificationCompat\|createNotificationChannel" --include="*.kt"
# Then check notification frequency/scheduling

# Check for debt collection related strings:
grep -rn "cobro\|cobranza\|mora\|deuda\|vencido\|atrasado\|overdue\|default\|delinquent" --include="*.xml" --include="*.kt" -i

# Check for emergency contact usage beyond declared purpose:
grep -rn "emergency.*contact\|contacto.*emergencia\|reference.*contact" --include="*.kt" -i
```

- [ ] No READ_CONTACTS permission (or explicitly removed via tools:node="remove")
- [ ] No automated SMS sending to user's contacts
- [ ] No automated calling to user's contacts
- [ ] Emergency contact data used ONLY for loan application, NOT for collection
- [ ] Notification frequency is reasonable (not spamming overdue reminders)
- [ ] No threatening or shaming language in any UI or notification

### 14.2 Predatory Lending Indicators

Google flags apps that exhibit predatory lending patterns:

**Code audit**:
```bash
# Check for extremely short loan terms:
grep -rn "repayment.*day\|plazo.*dia\|term.*day\|loan.*period" --include="*.kt" --include="*.xml" -i
# Verify minimum repayment period >= 60 days

# Check for hidden fees:
grep -rn "fee\|cargo\|comision\|cuota.*manejo\|penalty\|penalidad\|recargo" --include="*.xml" --include="*.kt" -i

# Check for maximum APR disclosure:
grep -rn "APR\|tasa.*anual\|interest.*rate\|tasa.*interes" --include="*.xml" --include="*.kt" -i
```

- [ ] Minimum loan repayment period >= 60 days (< 60 days = **BLOCKER**)
- [ ] All fees clearly disclosed before loan agreement
- [ ] APR clearly displayed and not misleading
- [ ] No hidden fees or charges added after loan agreement
- [ ] No excessive late payment penalties

### 14.3 Data Usage for Lending Decisions

**Policy**: Loan apps must NOT use certain data types for credit scoring or lending decisions:

| Data Type | Use for Credit Scoring | Policy |
|-----------|----------------------|--------|
| SMS content | PROHIBITED | Spyware Policy |
| Contact list | PROHIBITED | Personal Loans Policy |
| Installed apps | PROHIBITED | QUERY_ALL_PACKAGES Policy |
| Photos/media | PROHIBITED | Personal Loans Policy |
| Fine location | PROHIBITED | Personal Loans Policy |
| Coarse location | ALLOWED with disclosure | Must declare in Data Safety |
| Device ID | ALLOWED with disclosure | Must declare in Data Safety |
| Financial records (credit bureau) | ALLOWED | Standard practice |

**Code audit**:
```bash
# Check if SMS data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "sms\|message"

# Check if app list flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "app\|package\|install"

# Check if contact data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "contact"
```

- [ ] SMS data NOT used for credit scoring (even if collected for other purposes)
- [ ] Installed app data NOT used for credit scoring
- [ ] Contact data NOT used for credit scoring
- [ ] Photos/media NOT used for credit scoring
- [ ] Fine location NOT used for credit scoring

### 14.4 Loan App Harassment Checklist

- [ ] No contact list access for debt collection
- [ ] No automated communication to user's contacts
- [ ] Emergency contacts protected from collection use
- [ ] Reasonable notification frequency
- [ ] No threatening or shaming language
- [ ] Loan terms >= 60 days minimum
- [ ] All fees disclosed upfront
- [ ] Prohibited data types not used for lending decisions

---

## 15. Developer Verification (2026)

### 15.1 New Requirement

Starting September 2026, Google will require **all Android apps** installed on certified devices to be registered by **verified developers**.

### 15.2 Rollout Schedule

| Date | Region |
|------|--------|
| September 2026 | Brazil, Indonesia, Singapore, Thailand |
| 2027+ | Other regions (gradual rollout) |
| September 2027 | Managed devices (DO) and Work Profiles (BYOD/COPE) |

### 15.3 Impact

- Apps from unverified developers will not install on certified devices
- Existing apps may need developer re-verification
- Enterprise/MDM apps have extended timeline until September 2027

### 15.4 Action Items

- [ ] Verify developer identity in Play Console
- [ ] Ensure organization details (name, address, DUNS) are up to date
- [ ] Prepare for additional verification for Latin American regions (Brazil first batch)

---

## 16. Testing Tracks

### 16.1 Recommended Release Flow

```
Internal Testing → Closed Testing → Open Testing → Production
```

| Track | Audience | Data Safety Required | Financial Declaration Required | Review |
|-------|----------|---------------------|-------------------------------|--------|
| Internal | Up to 100 testers | No | No | No review |
| Closed | Invited testers | Yes | Yes | Full review |
| Open | Anyone can join | Yes | Yes | Full review |
| Production | All users | Yes | Yes | Full review |

### 16.2 Pre-Launch Report

- [ ] Enable pre-launch report in Play Console
- [ ] Review automated test results (crashes, performance, accessibility)
- [ ] Fix critical issues before promotion to production
- [ ] Test on Pixel devices (Google reviewers use these)
- [ ] Test on multiple API levels (min SDK through target SDK)

### 16.3 AI Review Preparation

Google's review system is increasingly AI-driven. To reduce false rejections:
- [ ] App description precisely matches actual functionality
- [ ] No unused permissions in manifest
- [ ] Data Safety form exactly matches code behavior
- [ ] All SDK data collection declared (Google ML cross-checks APK)
- [ ] No obfuscated or hidden functionality
- [ ] Test account credentials provided if login required

---

## 17. Post-Launch Monitoring

### 17.1 Play Vitals Thresholds

| Metric | Threshold | Action if Exceeded |
|--------|-----------|-------------------|
| ANR rate | 0.47% | App may be deprioritized in search |
| Crash rate | 1.09% | App may be deprioritized in search |
| Permission denial rate | High = bad UX signal | Review permission strategy |
| Uninstall rate | Spike after update | Investigate regression |

### 17.2 Enforcement Actions

If policy violated:
1. **Warning** → fix within deadline (usually 7-30 days)
2. **App removal** → fix and resubmit
3. **Account suspension** → repeated violations or egregious breach

**Scale of enforcement**: From early 2024 to April 2025, approximately 1.8 million apps were removed from the Play Store.

### 17.3 Checklist

- [ ] Crash reporting enabled (Firebase Crashlytics or equivalent)
- [ ] ANR monitoring configured
- [ ] Play vitals dashboard reviewed regularly
- [ ] Review response workflow established (respond to 1-star reviews promptly)
- [ ] ProGuard mapping uploaded for each release (crash deobfuscation)

---

## 18. Code-Level Audit Checklist

Run these checks against your codebase before submission:

### 18.1 Manifest Audit

```bash
# SMS/Call Log permissions — requires Permissions Declaration Form and exception approval:
grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|READ_CALL_LOG\|WRITE_CALL_LOG" AndroidManifest.xml

# BLOCKER for personal loan apps — explicitly prohibited by Personal Loans policy:
grep -n "READ_CONTACTS\|WRITE_CONTACTS\|READ_PHONE_NUMBERS" AndroidManifest.xml
grep -n "QUERY_ALL_PACKAGES" AndroidManifest.xml

# Photo/Video permissions (need declaration):
grep -n "READ_MEDIA_IMAGES\|READ_MEDIA_VIDEO\|READ_EXTERNAL_STORAGE" AndroidManifest.xml

# Foreground service type check:
grep -n "<service" AndroidManifest.xml | grep -v "foregroundServiceType"

# Exported components without protection:
grep -n "exported=\"true\"" AndroidManifest.xml

# Backup configuration:
grep -n "allowBackup" AndroidManifest.xml
```

### 18.2 Code Audit

```bash
# Debug logging in production — USE CONTEXT-AWARE CHECK (see Section 1.4 methodology):
# WRONG: grep -rn "Log\.\(d\|v\|i\)\(" --include="*.kt" app/src/main/ | grep -v "BuildConfig.DEBUG"
#   ^^^ This produces FALSE POSITIVES when BuildConfig.DEBUG guard is on the line above!
#
# CORRECT: Check with surrounding context, then manually verify each match:
grep -rn -B 3 "Log\.\(d\|v\|i\)\(" --include="*.kt" app/src/main/
# For each match: verify if (BuildConfig.DEBUG) exists within 1-3 lines above.
# Only flag matches where NO guard is found in the context window.

# Unguarded printStackTrace() — same context-aware approach:
grep -rn -B 3 "printStackTrace" --include="*.kt" app/src/main/
# Verify each has BuildConfig.DEBUG guard within 1-3 lines above.

# Hardcoded secrets:
grep -rn "apiKey\|api_key\|secret\|password\|token" --include="*.kt" --include="*.gradle*" | grep -v "BuildConfig\." | grep -v "test/"

# Sensitive data in URLs:
grep -rn "token=\|key=\|password=\|secret=" --include="*.kt" app/src/main/

# Device ID collection (must be declared in Data Safety):
grep -rn "ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId" --include="*.kt"

# SMS content access (requires exception approval; PROHIBITED for credit scoring in loan apps):
grep -rn "Telephony.Sms\|SmsMessage\|pdus" --include="*.kt"

# Installed apps enumeration:
grep -rn "getInstalledPackages\|getInstalledApplications\|queryIntentActivities" --include="*.kt"
```

### 18.3 Build Config Audit

```bash
# Check targetSdk:
grep -rn "targetSdk\|targetSdkVersion" --include="*.gradle*"

# Check minify/shrink:
grep -rn "minifyEnabled\|shrinkResources" --include="*.gradle*"

# Check signing configs for hardcoded values:
grep -rn "storePassword\|keyPassword" --include="*.gradle*"

# Check for debug-only code that might leak to release:
grep -rn "BuildConfig.DEBUG" --include="*.kt" -c
```

---

### 18.4 Spyware & Consent Flow Audit

```bash
# Consent dialog — does "decline" actually prevent data collection?
grep -rn "okListener\|confirmListener\|agreeListener" --include="*.kt" -A 3
grep -rn "refuseListener\|cancelListener\|declineListener" --include="*.kt" -A 3

# SDK initialization before consent (BLOCKER if found):
grep -rn "class.*Application.*:" --include="*.kt" -l
# Then check each Application class for SDK init in onCreate()

grep -rn "AppsFlyerLib.*init\|AppsFlyerLib.*start" --include="*.kt"
grep -rn "FirebaseApp.initializeApp" --include="*.kt"
grep -rn "FacebookSdk.*initialize" --include="*.kt"

# SMS body content upload check:
grep -rn "SP_BODY\|sms_body\|message_body" --include="*.kt" | grep -i "add\|put\|property"

# Incremental/continuous SMS harvesting:
grep -rn "SMS_SUCCESS_TIME\|last.*sms.*time\|sms.*timestamp" --include="*.kt"

# SMS filtering adequacy — check SQL LIKE patterns:
grep -rn "LIKE\|like" --include="*.kt" | grep -i "sms\|body\|message"
```

### 18.5 Device Abuse Audit

```bash
# Device settings modification:
grep -rn "Settings.System\|Settings.Secure\|Settings.Global" --include="*.kt" | grep -i "put\|write\|set"

# Accessibility service abuse:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt"

# Device admin / preventing uninstall:
grep -rn "DeviceAdminReceiver\|DevicePolicyManager\|BIND_DEVICE_ADMIN" --include="*.kt" --include="*.xml"

# Remote code execution (CRITICAL):
grep -rn "DexClassLoader\|PathClassLoader\|InMemoryDexClassLoader" --include="*.kt"
grep -rn "Runtime.getRuntime().exec\|ProcessBuilder" --include="*.kt"

# System UI mimicry:
grep -rn "AlertDialog" --include="*.kt" | grep -i "system\|update\|warning\|virus\|security"
```

### 18.6 Loan App Harassment Audit

```bash
# Contact list access for collection:
grep -rn "ContactsContract\|READ_CONTACTS" --include="*.kt"

# Automated SMS/calling to contacts:
grep -rn "SmsManager\|sendTextMessage" --include="*.kt"
grep -rn "ACTION_CALL\b" --include="*.kt"

# Debt collection language:
grep -rn "cobro\|cobranza\|mora\|deuda\|vencido\|atrasado" --include="*.xml" --include="*.kt" -i

# Aggressive notification scheduling:
grep -rn "NotificationManager\|NotificationCompat" --include="*.kt" | grep -i "overdue\|payment\|remind\|cobr"

# Data used for credit scoring (should NOT include SMS, apps, contacts):
grep -rn "risk\|score\|credit\|assess" --include="*.kt" -i | grep -i "sms\|message\|app\|package\|contact"
```

---

## 19. Launch Day Checklist (Final)

```markdown
## Pre-Submit
- [ ] Target API level >= 35
- [ ] AAB format (not APK)
- [ ] R8/ProGuard enabled, resources shrunk
- [ ] Version code incremented
- [ ] ProGuard mapping saved
- [ ] SMS/Call Log permissions: either removed, or Permissions Declaration Form submitted with exception approval
- [ ] Personal loan apps: no prohibited permissions (contacts, photos, phone numbers, fine location)
- [ ] All foreground services have declared types

## Play Console
- [ ] App signing configured (Play App Signing)
- [ ] Store listing complete (icon, screenshots, descriptions)
- [ ] Financial Features Declaration completed
- [ ] Content rating questionnaire completed
- [ ] Data Safety form completed (ALL SDKs audited)
- [ ] Privacy policy URL active and linked
- [ ] Account deletion web link provided
- [ ] Contact email configured
- [ ] Pricing & distribution set
- [ ] All Permissions Declaration Forms submitted

## Financial App Specific
- [ ] App category = "Finance"
- [ ] Loan terms in app description (APR, repayment, representative cost)
- [ ] Licensing documents uploaded for target countries
- [ ] No short-term loans (< 60 days)
- [ ] No access to photos/contacts for lending decisions (SMS governed by Section 3.1 exception policy)

## Spyware & Privacy (Section 11)
- [ ] Prominent disclosure shown BEFORE any data collection or SDK init
- [ ] User can DECLINE data collection and still use basic functionality
- [ ] No SDK transmits data before user consent
- [ ] No personal SMS content uploaded to server
- [ ] All collected data types disclosed in consent + privacy policy + Data Safety
- [ ] No data collection unrelated to app functionality
- [ ] No background data uploads without user-visible notification

## Deceptive Behavior (Section 10)
- [ ] No system UI mimicry
- [ ] No hidden functionality or remote code execution
- [ ] Disclosure-vs-reality gap audit passed (all collected data is disclosed)
- [ ] No behavior changes based on undisclosed server flags

## Device Abuse (Section 12)
- [ ] No device settings modification
- [ ] No accessibility service abuse
- [ ] No app interference or preventing uninstallation

## Loan App Harassment (Section 14)
- [ ] No contact access for debt collection
- [ ] No automated messages to user's contacts
- [ ] No threatening/shaming language
- [ ] Prohibited data NOT used for credit scoring

## Consent Flow (Section 13)
- [ ] Consent → Permission → Collection order verified
- [ ] Each permission denial handled gracefully
- [ ] Loading indicator during data uploads
- [ ] Third-party data sharing disclosed

## Policy
- [ ] No deceptive behavior
- [ ] Permissions minimal and justified
- [ ] Account deletion available in-app and via web link
- [ ] Privacy policy matches Data Safety declarations

## Testing
- [ ] Internal testing track verified
- [ ] Closed testing track passed review
- [ ] Pre-launch report reviewed (no critical issues)
- [ ] Tested on Pixel devices
- [ ] No crashes or ANRs above threshold

## Submit
- [ ] Release notes written (what's new)
- [ ] Staged rollout configured (start at 10-20%)
- [ ] Monitoring dashboards ready
- [ ] Review response team alerted
```

---

## 20. Common Rejection Reasons & Fixes

| Rejection | Root Cause | Fix | Priority |
|-----------|-----------|-----|----------|
| Deceptive behavior | Metadata doesn't match functionality | Align descriptions with actual features | BLOCKER |
| Data Safety mismatch | SDK collects data not declared | Audit all SDKs, update Data Safety form | BLOCKER |
| Privacy policy missing/broken | No policy URL or returns 404 | Host policy and link in Console + app | BLOCKER |
| Financial declaration missing | Not completed in Play Console | Complete Financial Features Declaration | BLOCKER |
| Restricted permission misuse | READ_SMS without exception approval, or READ_CONTACTS/QUERY_ALL_PACKAGES in loan app | Submit Permissions Declaration Form for SMS exception, or remove prohibited permissions | BLOCKER |
| Over-permissioning | Unnecessary permissions | Remove unused permissions from manifest | BLOCKER |
| No account deletion | Missing in-app or web deletion | Implement account + data deletion flow | BLOCKER |
| Minimum functionality | App is essentially a WebView wrapper | Add native functionality beyond WebView | BLOCKER |
| Impersonation | Logo/name similar to known brand | Change branding to be clearly distinct | BLOCKER |
| Broken functionality | Crashes on review device | Test on Pixel devices, fix pre-launch report | BLOCKER |
| API level too low | targetSdk below 35 | Update to API 35+ | BLOCKER |
| Spyware - no consent | Data collected before user consent shown | Move SDK init after consent dialog | BLOCKER |
| Spyware - SMS exfiltration | Personal SMS content uploaded to server | Remove SMS body upload or use SMS Retriever API | BLOCKER |
| Spyware - covert transmission | SDKs transmit data before consent dialog | Delay SDK initialization until after consent | BLOCKER |
| Spyware - excessive collection | Data unrelated to app function collected | Remove unnecessary data points (hardware fingerprint, NFC, etc.) | BLOCKER |
| Consent decline ineffective | Decline/Cancel does same as Accept | Make decline genuinely prevent data collection | BLOCKER |
| Disclosure gap | Collected data not mentioned in consent dialog | Update consent dialog to list all data types | BLOCKER |
| Loan harassment | Contact access used for debt collection | Remove READ_CONTACTS, ensure contacts not used for collection | BLOCKER |
| Predatory lending | Loan terms < 60 days or hidden fees | Ensure minimum 60 day terms, disclose all fees | BLOCKER |
| Hidden functionality | DexClassLoader or remote code execution | Remove dynamic code loading | BLOCKER |
| Missing FGS type | Foreground service without type declaration | Add foregroundServiceType in manifest | WARNING |
| Photo permission without declaration | READ_MEDIA_IMAGES without form | Submit declaration or switch to Photo Picker | WARNING |
| Missing loan terms | APR/repayment not in description | Add required disclosures to listing | WARNING |
| Device fingerprint not declared | MediaDrm/Build.FINGERPRINT collected but not in Data Safety | Add to Data Safety form | WARNING |
| Background data upload | Data sent when app in background without notification | Ensure uploads only in foreground or show notification | WARNING |

---

## 21. Key Policy Deadlines (2025-2026)

| Date | Requirement | Impact |
|------|------------|--------|
| May 28, 2025 | Photo/Video permissions full compliance | App removal if non-compliant |
| May 28, 2025 | Line of credit apps must comply with Personal Loan policy | BLOCKER |
| August 31, 2025 | Target API 35 for new apps and updates | Submission blocked |
| October 30, 2025 | Financial Features Declaration required for all updates | Updates blocked |
| November 1, 2025 | API 35 extension deadline | No more extensions |
| January 1, 2026 | Age Signals API data use restriction | Policy enforcement |
| January 28, 2026 | Updated Developer Program Policies effective | Full enforcement |
| March 4, 2026 | Thailand loan app listing requirements | Existing apps |
| September 2026 | Developer Verification (Brazil, Indonesia, Singapore, Thailand) | Install blocked |
| 2027+ | Developer Verification (other regions) | Install blocked |

---

## References

- [Google Play Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/16810878?hl=en)
- [Policy Deadlines](https://support.google.com/googleplay/android-developer/table/12921780?hl=en)
- [Policy Announcements](https://support.google.com/googleplay/android-developer/announcements/13412212?hl=en)
- [Financial Features Declaration](https://support.google.com/googleplay/android-developer/answer/13849271?hl=en)
- [Financial Services Policy](https://support.google.com/googleplay/android-developer/answer/9876821?hl=en)
- [Permissions and APIs that Access Sensitive Information](https://support.google.com/googleplay/android-developer/answer/16585319?hl=en)
- [SMS/Call Log Permission Policy](https://support.google.com/googleplay/android-developer/answer/10208820?hl=en)
- [Permissions and APIs that Access Sensitive Information (Updated)](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en)
- [QUERY_ALL_PACKAGES Permission Policy](https://support.google.com/googleplay/android-developer/answer/10158779?hl=en)
- [Photo and Video Permissions Policy](https://support.google.com/googleplay/android-developer/answer/14115180?hl=en)
- [Foreground Service Requirements](https://support.google.com/googleplay/android-developer/answer/13392821?hl=en)
- [Account Deletion Requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en)
- [Data Safety Form Guide](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [Android Developer - Foreground Service Types](https://developer.android.com/develop/background-work/services/fgs/service-types)
- [Policy Announcement: April 10, 2025](https://support.google.com/googleplay/android-developer/answer/15899442?hl=en)
- [Policy Announcement: July 17, 2024](https://support.google.com/googleplay/android-developer/answer/14993590?hl=en)
- [Policy Announcement: July 10, 2025](https://support.google.com/googleplay/android-developer/answer/16296680?hl=en)
- [Android Developer - Default Handlers](https://developer.android.com/guide/topics/permissions/default-handlers)
- [Spyware Policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Deceptive Behavior Policy](https://support.google.com/googleplay/android-developer/answer/9888077?hl=en)
- [Device and Network Abuse Policy](https://support.google.com/googleplay/android-developer/answer/9888379?hl=en)
- [User Data Policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Prominent Disclosure Requirements](https://support.google.com/googleplay/android-developer/answer/11150561?hl=en)
- [Personal Loans Policy](https://support.google.com/googleplay/android-developer/answer/12005270?hl=en)
- [Stalkerware Policy](https://support.google.com/googleplay/android-developer/answer/10065570?hl=en)
