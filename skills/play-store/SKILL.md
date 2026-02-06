---
name: play-store
description: Google Play Store submission and compliance checklist. Use when preparing app for release, configuring Play Console, discussing store listing, Data Safety section, privacy policy, content rating, or testing tracks.
---

# Google Play Launch Checklist

Pre-submission audit and compliance verification for Google Play Store publishing.

## When to Use

- Preparing an app for first submission to Google Play
- Updating an existing app and submitting a new release
- Responding to Google Play policy violation notices
- Configuring Play Console settings (Data Safety, content rating, etc.)
- Debugging app rejection reasons

## Pre-Submission Audit Process

Evaluate the app against ALL categories below. Output findings as:

```
[GP-XXXXX] status: BLOCKER | WARNING | INFO
  Finding: <what is missing or wrong>
  Fix: <concrete action to resolve>
```

---

## 1. Build Configuration

### Target API Level (Mandatory)

From August 31, 2025:
- **New apps and updates** MUST target API 35 (Android 15) or higher
- **Existing apps** MUST target at least API 34 to remain visible on Android 15+ devices
- Wear OS / Android TV / Automotive: API 34 minimum

```kotlin
// build.gradle.kts
android {
    compileSdk = 35  // or higher
    defaultConfig {
        targetSdk = 35
        minSdk = 24    // balance reach vs. maintenance
    }
}
```

### App Bundle Format (Mandatory)

Google Play requires AAB (Android App Bundle), NOT APK:

```kotlin
// build.gradle.kts — already default in AGP 7.0+
android {
    bundle {
        language { enableSplit = true }
        density { enableSplit = true }
        abi { enableSplit = true }
    }
}
```

### Billing Library (if applicable)

Apps with in-app purchases MUST use Play Billing Library 7.0.0+:
```kotlin
implementation("com.android.billingclient:billing-ktx:7.1.1")
```

### Release Build Checklist

- [ ] `isMinifyEnabled = true` (R8 enabled)
- [ ] `isShrinkResources = true`
- [ ] `debuggable` NOT set to true (default is false for release)
- [ ] No `StrictMode` enabled in release
- [ ] No test/debug endpoints in release
- [ ] Version code incremented from previous release
- [ ] ProGuard mapping file saved for crash deobfuscation

---

## 2. App Signing

### Play App Signing (Mandatory for new apps)

All new apps MUST use Play App Signing. Google manages the app signing key.

```
Upload key (you keep) → signs AAB for upload
App signing key (Google keeps) → signs final APK for distribution
```

### Key Management

- [ ] Upload key stored securely (NOT in repo)
- [ ] Upload key password not hardcoded
- [ ] Backup of upload key exists in secure location
- [ ] If upload key is lost: request reset through Play Console (requires identity verification)

---

## 3. Store Listing

### Required Assets

| Asset | Specification |
|-------|--------------:|
| App icon | 512×512 PNG, 32-bit, no alpha |
| Feature graphic | 1024×500 PNG or JPEG |
| Screenshots | Min 2, max 8 per device type. Min 320px, max 3840px. JPEG or PNG |
| Phone screenshots | Required. 16:9 or 9:16 aspect ratio recommended |
| Tablet screenshots | Required if app supports tablets |
| Short description | Max 80 characters |
| Full description | Max 4000 characters |

### Listing Quality

- [ ] Title: accurate, no keyword stuffing (max 30 chars)
- [ ] Short description: clear value proposition
- [ ] Full description: features, not marketing fluff
- [ ] Screenshots: actual app UI, not mockups with misleading content
- [ ] No misleading claims about functionality
- [ ] No references to other platforms ("also on iOS")
- [ ] No excessive capitalization or emoji spam
- [ ] Contact email is valid and monitored

### Metadata Anti-Patterns (Rejection Triggers)

- NEVER use "best", "number 1", "#1" without third-party verification
- NEVER reference competitor app names
- NEVER include call-to-action in icon ("FREE", "SALE")
- NEVER show content in screenshots that differs from actual app
- NEVER use misleading app category

---

## 4. Data Safety Section (Mandatory)

### When Required

ALL apps on Google Play, including those that collect NO data.
Required for: closed testing, open testing, and production tracks.
Only exempted: internal testing track.

### What to Declare

For EVERY piece of data your app or ANY SDK collects:

| Data Category | Examples |
|--------------|---------|
| Location | Approximate, precise |
| Personal info | Name, email, user ID, address, phone |
| Financial info | Payment info, purchase history |
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
| Device or other IDs | Device ID, advertising ID |

### For Each Data Type, Declare

1. **Is it collected?** (transmitted off device)
2. **Is it shared?** (transferred to third parties)
3. **Is it required or optional?**
4. **Purpose:** App functionality, analytics, developer communications, advertising,
   fraud prevention, security, compliance, personalization, account management

### SDK Audit (Critical)

YOU are responsible for ALL data collected by third-party SDKs:

```
For each SDK in your app:
1. Check SDK documentation for data collection
2. Verify with SDK's own data safety guidance
3. Include SDK's data collection in YOUR Data Safety form
4. Google uses ML to cross-check — inconsistencies trigger review
```

Common SDKs and their data collection:
- **Firebase Analytics**: device ID, app activity, diagnostics
- **Firebase Crashlytics**: crash logs, device info
- **AdMob/Google Ads**: advertising ID, location, app activity
- **Facebook SDK**: device ID, app activity, advertising data
- **Adjust/AppsFlyer**: device ID, attribution data

### Checklist

- [ ] Data Safety form completed in Play Console
- [ ] ALL SDKs audited for data collection
- [ ] Collection matches actual app behavior (Google ML verifies)
- [ ] Data handling matches privacy policy
- [ ] Encryption in transit declared accurately
- [ ] Data deletion mechanism declared (if applicable)
- [ ] Updated whenever SDK or data practices change

---

## 5. Privacy Policy (Mandatory)

### Requirements

- [ ] Hosted on active, publicly accessible URL (NOT PDF, NOT geofenced)
- [ ] URL provided in Play Console designated field
- [ ] Link accessible within the app itself
- [ ] Entity name matches Play Console developer name
- [ ] Privacy contact info included

### Content Must Include

- [ ] What personal/sensitive data is collected
- [ ] How data is used
- [ ] How data is shared (and with whom)
- [ ] Data retention period
- [ ] Data deletion procedure (how users can request deletion)
- [ ] Security measures for data protection
- [ ] Third-party SDK data practices
- [ ] Children's data handling (if applicable)
- [ ] Contact information for privacy inquiries

### Anti-Patterns

- NEVER use a generic/template policy without customization
- NEVER host policy on a domain you don't control
- NEVER let the policy URL return 404
- NEVER omit SDK data collection from the policy

---

## 6. Content Rating (Mandatory)

### Process

1. Complete IARC (International Age Rating Coalition) questionnaire in Play Console
2. Answer questions about: violence, sexual content, language, controlled substances,
   user interaction, data sharing, location sharing, in-app purchases
3. Receive automatic ratings for multiple regions (ESRB, PEGI, etc.)

### Rules

- [ ] Content rating questionnaire completed
- [ ] Rating matches actual app content
- [ ] Re-submit questionnaire if app content changes significantly
- [ ] Apps without rating will be removed from Google Play

---

## 7. Policy Compliance

### Deceptive Behavior (Top Rejection Reason)

- NEVER misrepresent app functionality in metadata
- NEVER mimic system UI or other app warnings
- NEVER make undisclosed changes to device settings
- NEVER collect data without clear disclosure and consent
- NEVER hide app functionality that contradicts stated purpose

### Permissions

- [ ] Request ONLY permissions necessary for core functionality
- [ ] Explain each permission to user before requesting
- [ ] App functions gracefully when permissions denied
- [ ] NO location/contacts/SMS permission for advertising only
- [ ] Foreground service permissions declared and justified

### Ads Compliance (if applicable)

- [ ] No ads mimicking app UI or system notifications
- [ ] No fullscreen interstitial ads that can't be closed within 2 seconds
- [ ] No ads triggered by accidental taps (misleading close buttons)
- [ ] Ad SDKs declared in Data Safety section
- [ ] No personalized ads for children under 12 (Families Policy)
- [ ] Ad frequency reasonable (not overwhelming)

### Families Policy (if targeting children)

- [ ] Child Safety Standards self-certification completed
- [ ] No personalized advertising
- [ ] Age-appropriate content only
- [ ] Parental consent mechanisms implemented
- [ ] No data collection from children beyond minimum required

### User-Generated Content (if applicable)

- [ ] Content moderation system in place
- [ ] Reporting mechanism for objectionable content
- [ ] Terms of service prohibit illegal/policy-violating content
- [ ] In-app blocking functionality

---

## 8. Testing Tracks

### Recommended Release Flow

```
Internal Testing → Closed Testing → Open Testing → Production
```

| Track | Audience | Data Safety Required | Review |
|-------|----------|---------------------|--------|
| Internal | Up to 100 testers | No | No review |
| Closed | Invited testers | Yes | Full review |
| Open | Anyone can join | Yes | Full review |
| Production | All users | Yes | Full review |

### Pre-Launch Report

- [ ] Enable pre-launch report in Play Console
- [ ] Review automated test results (crashes, performance, accessibility)
- [ ] Fix critical issues before promotion to production
- [ ] Test on multiple device configurations

---

## 9. Post-Launch Monitoring

### Key Metrics to Watch

- **ANR rate**: must stay below 0.47% (Play vitals threshold)
- **Crash rate**: must stay below 1.09% (Play vitals threshold)
- **Permission denial rate**: high denial = bad UX signal
- **Uninstall rate**: spike after update = regression
- **User ratings**: respond to 1-star reviews promptly

### Enforcement Actions

If policy violated:
1. **Warning** → fix within deadline
2. **App removal** → fix and resubmit
3. **Account suspension** → repeated violations

### Checklist

- [ ] Crash reporting enabled (Firebase Crashlytics or equivalent)
- [ ] ANR monitoring configured
- [ ] Play vitals dashboard reviewed regularly
- [ ] Review response workflow established

---

## Launch Day Checklist (Final)

```markdown
## Pre-Submit
- [ ] Target API level ≥ 35
- [ ] AAB format (not APK)
- [ ] R8/ProGuard enabled
- [ ] Version code incremented
- [ ] ProGuard mapping saved

## Play Console
- [ ] App signing configured
- [ ] Store listing complete (icon, screenshots, descriptions)
- [ ] Content rating questionnaire completed
- [ ] Data Safety form completed (ALL SDKs audited)
- [ ] Privacy policy URL active and linked
- [ ] Contact email configured
- [ ] Pricing & distribution set

## Policy
- [ ] No deceptive behavior
- [ ] Permissions minimal and justified
- [ ] Ad compliance (if applicable)
- [ ] Families policy (if applicable)

## Testing
- [ ] Internal testing track verified
- [ ] Closed testing track passed
- [ ] Pre-launch report reviewed
- [ ] No critical crashes or ANRs

## Submit
- [ ] Release notes written (what's new)
- [ ] Staged rollout configured (start at 10-20%)
- [ ] Monitoring dashboards ready
```

## Common Rejection Reasons & Fixes

| Rejection | Root Cause | Fix |
|-----------|-----------|-----|
| Deceptive behavior | Metadata doesn't match functionality | Align descriptions with actual features |
| Data Safety mismatch | SDK collects data not declared | Audit all SDKs, update Data Safety form |
| Privacy policy missing | No policy URL or 404 | Host policy and link in Console + app |
| Over-permissioning | Unnecessary permissions | Remove unused permissions from manifest |
| Minimum functionality | App is essentially a WebView wrapper | Add native functionality beyond WebView |
| Impersonation | Logo/name similar to known brand | Change branding to be clearly distinct |
| Broken functionality | Crashes on review device | Test on Pixel devices and review pre-launch report |
| API level too low | targetSdk below requirement | Update to API 35+ |
