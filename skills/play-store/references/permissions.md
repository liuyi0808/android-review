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
- [3.9 Contacts Permissions](#39-contacts-permissions)
- [3.10 Permissions Checklist Summary](#310-permissions-checklist-summary)
- [3.11 Local Network and Manage Contacts](#311-local-network-and-manage-contacts)
- [3.12 All Files Access and Accessibility](#312-all-files-access-and-accessibility)
- [3.13 AppFunctions](#313-appfunctions)

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
| **Call-based authentication and authorization in banking or brokerage apps** | Until January 27, 2027, check the current banking/brokerage exception and evidence of approval. A loan app does not qualify merely because it offers loans. From January 27, `READ_CALL_LOG` is not allowed for phone-call account verification ([preview](https://support.google.com/googleplay/android-developer/answer/17225965)). | Check the exact permissions and purpose in the current exception table. |
| **SMS-based money management** | For example, apps that track and manage budget | `READ_SMS`, `RECEIVE_MMS`, `RECEIVE_SMS`, `RECEIVE_WAP_PUSH` |

> **Note**: All eligible permissions are subject to Google Play review and approval. The full exception table includes additional non-financial categories (caller ID, backup & restore, connected device companion, device automation, enterprise archive, etc.) — see [full list](https://support.google.com/googleplay/android-developer/answer/10208820).

**October 29 clarifications** ([current policy](https://support.google.com/googleplay/android-developer/answer/10208820)): The `READ_CALL_LOG` exception for government-mandated telecommunications quality-of-service reporting is for qualifying government or authorized mobile network operator apps. It is not an exception for loan credit checks, KYC or collection. For a backup/restore claim, require evidence that the app restores the data to the original default handler; a cloud upload or in-app export alone is insufficient.

**Evidence for loan apps**: Separate account OTP, financial transaction verification, SMS-based money management, underwriting, and collections. Trace the provider or receiver to the actual fields, decisions, destinations and user flow, then compare with the approved Play Console use case. A keyword filter, a disclosure, or a field named `financialSms` does not establish an eligible use. Missing evidence is `NEEDS_CONFIRMATION`; an independently proven prohibited use does not become acceptable through disclosure or declaration.

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

Apply the [Financial Services General Requirements](https://support.google.com/googleplay/android-developer/answer/9876821) first to the submitted app: personal loans, apps primarily facilitating access to personal loans or lines of credit, accessory loan/credit apps, and EWA apps. The listed permission bans do not depend on whether access is used for underwriting. Verify effective declarations in the submitted variant's merged manifest or supplied artifact, including SDK contributions and manifest removals. Do not infer a ban from a name in a comment or from a declaration removed in the submitted variant.

**Prohibited permissions for personal loan apps** (since May 31, 2023, updated April 2025):
- `READ_CONTACTS`
- `READ_PHONE_NUMBERS`
- `ACCESS_FINE_LOCATION`
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`
- `QUERY_ALL_PACKAGES`

**SMS and Call Log**: Neither group is on the eight-permission list. Apply the separate SMS/Call Log permission policy and Spyware policy (Sections 3.1.1–3.1.2). An approval for transaction verification or money management does not authorize underwriting or collections. Sharing or exfiltrating non-financial or personal SMS history is a separate policy issue.

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
- Account verification via phone call using `READ_CALL_LOG` (from January 27, 2027; before then check the narrow existing exception in §3.1.1)
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
| **SMS OTP & account verification** | [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview), [SMS User Consent API](https://developers.google.com/identity/sms-retriever/user-consent/overview) for user-approved access to a single verification message, or manual entry. None justifies SMS history access. |
| **Migration away from `READ_CALL_LOG` account verification** | [Digital Credentials API for phone-number verification](https://developer.android.com/identity/digital-credentials/phone-number-verification) or a permissionless SMS verification flow. Check which API fits the product; these are alternatives, not a required SDK. |
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

**Policy** ([policy preview](https://support.google.com/googleplay/android-developer/answer/16909972#location-permissions), [foreground location guide and FAQ](https://support.google.com/googleplay/android-developer/answer/17033915)): Use the minimum location scope necessary for core functionality; prefer approximate location when sufficient. The updated requirements take effect January 27, 2027. Apply the 30-day Play Console self-extension only if the developer can show it was obtained for the app and verify the resulting deadline.

**Location button (target API 37+, effective January 27, 2027)**: For one-time or infrequent foreground precise location, use the Android location button. When the button is the only precise-location path, verify `android:usesPermissionFlags="onlyForLocationButton"` on the effective `ACCESS_FINE_LOCATION` entry in the submitted variant's merged manifest or packaged manifest. Verify the real entry point and session-limited access; a flag alone is not proof. For covered loan apps the `ACCESS_FINE_LOCATION` ban still applies, including when the flag is present. Audit approximate location independently for necessity, disclosure, and actual use.

```xml
<uses-permission
    android:name="android.permission.ACCESS_FINE_LOCATION"
    android:usesPermissionFlags="onlyForLocationButton" />
```

**Play Console declaration**: Google's foreground location guide requires apps requesting `ACCESS_FINE_LOCATION` to complete a declaration. For an effective request where the loan ban does not apply, verify the applicable form and its status in Play Console, including for button-only manifests; do not limit this check to persistent tracking. When the app requests precise location outside the button path, verify the core feature and the documented technical reason why approximate location or the button is insufficient. Record missing declaration evidence as `NEEDS_CONFIRMATION`. Evaluate background location and location FGS under their separate requirements; the button does not authorize background use.

**For loan apps**: `ACCESS_FINE_LOCATION` is **entirely prohibited** by the Personal Loans policy regardless of purpose (see Section 3.1.4 and loan-harassment.md). If location is genuinely required for anti-fraud, use `ACCESS_COARSE_LOCATION` only, declare it in Data Safety, and explain the use to users.

**Code audit**:
```bash
# Discovery only: inspect the complete permission element in the effective manifest.
grep -nE 'usesPermissionFlags|onlyForLocationButton' AndroidManifest.xml
grep -n "ACCESS_FINE_LOCATION\|ACCESS_COARSE_LOCATION\|ACCESS_BACKGROUND_LOCATION" AndroidManifest.xml
```

- [ ] `ACCESS_FINE_LOCATION` only if precise location is core functionality (prohibited for loan apps)
- [ ] `ACCESS_COARSE_LOCATION` preferred over fine location when possible
- [ ] One-time or infrequent precise location uses the system button when required; verify the effective fine-location entry's `usesPermissionFlags` for button-only access
- [ ] For effective `ACCESS_FINE_LOCATION`, verify the applicable Play Console declaration status and the case for any access outside the button path
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

**Geofencing (January 27, 2027)** ([Policy Deadlines](https://support.google.com/googleplay/android-developer/table/12921780)): Geofencing is removed as an approved location FGS use case. Trace the actual service purpose; `GeofencingClient` and a location FGS in the same app do not prove the service performs geofencing. The Geofence API does not exempt a loan app from the precise-location ban.

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

### 3.9 Contacts Permissions

**Policy** (announced April 15, 2026, [source](https://support.google.com/googleplay/android-developer/answer/16926792)): Google Play introduced the Contacts Permissions policy to govern **broad access** of users' contacts. Apps that do not need broad access must use the **Android Contact Picker**, a standardized secure picker introduced in Android 17 that grants access only to the specific contacts the user selects.

**Scope**: Apps that target Android 17+ (API level 37+) may only request `READ_CONTACTS` if the Android Contact Picker is insufficient for core functionality. Apps that continue to request broad contacts access without a justified use case will be subject to enforcement, including removal from Google Play.

**Enforcement timeline**:
- **January 27, 2027** — general `READ_CONTACTS` minimum-scope policy takes effect for target API 37+ ([preview](https://support.google.com/googleplay/android-developer/answer/16909972), [deadlines](https://support.google.com/googleplay/android-developer/table/12921780)). The Personal Loans ban is already in effect.

**For covered loan apps**: `READ_CONTACTS` is prohibited regardless of purpose (§3.1.4). A contact picker or a manually entered reference is not itself proof of a broad-read permission violation. Trace which contact fields are obtained, whether they're required for the loan, where they're sent, who can access them, and whether they feed risk assessment or collection. A picker is not a safe harbor for prohibited sensitive-data access or harassment; cite each independently proven outcome rather than issuing an automatic double finding.

**For a legitimate contact-sharing feature**: verify the app uses the [Android 17 Contact Picker](https://developer.android.com/about/versions/17/features/contact-picker) where required. Do not assume a legacy `ACTION_PICK` intent is the same API.

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
- [ ] No prohibited contacts access in covered loan apps; assess picker/manual flows by data and purpose
- [ ] Contact Picker used for one-time contact selection use cases
- [ ] Contact data not exfiltrated or transmitted beyond declared use

### 3.10 Permissions Checklist Summary

- [ ] Every permission in manifest has documented business justification
- [ ] Pre-permission rationale dialog shown before runtime permission requests
- [ ] App functions gracefully when ANY permission is denied
- [ ] All Permissions Declaration Forms submitted in Play Console
- [ ] No permissions declared "just in case" — unused permissions removed

### 3.11 Local Network and Manage Contacts

**Effective August 25, 2027** ([policy preview](https://support.google.com/googleplay/android-developer/answer/16909972), [deadlines](https://support.google.com/googleplay/android-developer/table/12921780)). Apply only to the relevant permission/use:

| Permission | Trigger | Evidence to review |
|---|---|---|
| `ACCESS_LOCAL_NETWORK` | Target API 37+ | Identify the feature that discovers or connects to local devices, data actually accessed and shared, why a device picker cannot support the core feature, and the Play Console declaration. For a loan app, distinguish normal internet API traffic from LAN access; trace any SDK-driven discovery or risk-data collection. |
| `MANAGE_CONTACTS` | Target API 38+ | Identify the edit/write/management operations and why scoped insert/edit intents cannot support the core feature; verify the Play Console declaration. Do not treat this as `READ_CONTACTS` or assume declaration makes prohibited loan data access acceptable. |

### 3.12 All Files Access and Accessibility

**All Files Access** ([current policy](https://support.google.com/googleplay/android-developer/answer/16558241#all_files)): For `MANAGE_EXTERNAL_STORAGE` on target API 30+, verify the core file-management need, why scoped platform alternatives are insufficient, the declaration, and the special-app-access prompt if granted. Apps must not request device storage access on a third party's behalf for any purpose unrelated to core functionality. This is an active restriction clarified in the October 2026 announcement, not an upcoming requirement. Trace SDK and partner-driven requests as well as app code; record whose purpose the access serves. In loan flows, trace what the app actually reads (for example, borrower-selected documents versus unrelated storage); distinguish the separate loan ban on listed storage/media permissions from the All Files Access declaration question.

**Accessibility** ([policy](https://support.google.com/googleplay/android-developer/answer/16558241#accessibility), [declaration and FAQ](https://support.google.com/googleplay/android-developer/answer/10964491)): For target API 31+ with `AccessibilityService`, verify Play Console declaration and approval, including applicable demo video evidence. Inspect the service XML, `isAccessibilityTool` designation and actual behavior. Non-tool apps must document API use in the Play listing, show prominent in-app disclosure and obtain affirmative consent. Use narrower APIs when possible. Bypassing Android security/privacy controls or recording remote call audio is prohibited. Automation on the user's behalf must have a narrow, clearly understood purpose; deterministic rules are not prohibited by the autonomy rule alone. Only eligible, verified accessibility tools may invoke the autonomy exception, and only for their core purpose of assisting people with disabilities. A service class, flag, gesture API or action constant alone is not evidence of abuse or exemption.

### 3.13 AppFunctions

**Effective April 14, 2027** ([policy preview](https://support.google.com/googleplay/android-developer/answer/16909972#appfunctions)). If the app exposes functions, compare each function's declared name, description and inputs to its runtime behavior. Verify inputs are limited to the operation; review actual data access, share/collect behavior and Data Safety coverage. Check for deceptive agent-facing instructions, attempts to bypass security/privacy controls, or interference with other apps or tools. For loan functions, exercise application/repayment actions with test data and verify the documented result and applicable consent and authorization boundaries; the API does not displace Financial Services or User Data rules.

- Runtime responses must not dynamically return hidden system instructions or prompts. Verify that instructions intended for agents are declared at function registration or metadata ingestion.
- AppFunctions must not reference or attempt to dictate execution rules for another app's AppFunctions. Inspect registered metadata and representative runtime responses, not just the dependency or annotation.
