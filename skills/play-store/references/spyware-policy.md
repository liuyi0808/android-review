# Spyware & User Data Policy (CRITICAL)

## Table of Contents
- [11.1 Category 1: Data Collection Without Adequate Notice](#111-category-1-data-collection-without-adequate-notice)
- [11.2 Category 2: Covert Data Transmission](#112-category-2-covert-data-transmission)
- [11.3 Category 3: Data Collection Unrelated to App Functionality](#113-category-3-data-collection-unrelated-to-app-functionality)
- [11.4 Category 4: Personal SMS/Call Log Exfiltration](#114-category-4-personal-smscall-log-exfiltration-critical-for-loan-apps)
- [11.5 Spyware Policy Checklist](#115-spyware-policy-checklist)

---

**Note**: The four categories below are an **organizational framework for this audit guide**, not Google's official categorization. Google's [Spyware policy](https://support.google.com/googleplay/android-developer/answer/9888380#spyware) addresses these concerns without using numbered categories. The categorization is derived from the policy requirements and violation examples listed in [Understanding Google Play's Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000).

**Financial/loan apps are under heightened scrutiny** because they handle sensitive financial data and historically have the highest violation rates.

**Policy reference**: [Understanding Google Play's Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000) | [Spyware policy (full)](https://support.google.com/googleplay/android-developer/answer/9888380#spyware)

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
- **Explicit consent UI**: Official guidance requires at least two options — one to allow (e.g., "Agree") and one to decline. Using clear language such as "Agree" is recommended ([source](https://support.google.com/googleplay/android-developer/answer/11150561))
- **Granular consent**: *(audit guidance)* Consider allowing users to consent to some data types and decline others

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

**Note**: The "justified" and "hard to justify" lists below are **audit guidance** based on the policy principle that data collection must be "necessary" and "reasonably expected" ([User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311)). Google does not provide specific lists for financial apps — these categorizations reflect industry practice and enforcement patterns.

**For financial/loan apps**, the following MAY be justified (with proper disclosure):
- Financial SMS (for transaction verification — requires SMS exception approval per Section 3.1)
- Location (for fraud detection — `ACCESS_FINE_LOCATION` is banned for loan apps; only coarse location allowed)
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

#### Policy Requirements

The [Spyware policy](https://support.google.com/googleplay/android-developer/answer/9888380) provides a non-exhaustive list of practices that are considered spyware violations. From [Understanding Google Play's Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000):

> Examples of Spyware policy violations:
> - An app that uses an SDK which transmits data from audio or call recordings when it is not related to policy compliant app functionality.
> - An application that steals information from other apps' notifications.
> - Transmitting any of the following non-exhaustive list of information without policy compliant functionality or in a manner that is unexpected to the user (for example, if data collection occurs in the background when the user is not engaging with your app): Contact list, Photos or other files from the SD card **that aren't owned by the app**, Content from user email, Call log, **SMS log**, Information from the /data/ directories of other apps.
> - **Personal loans or budgeting apps exfiltrating or sharing non-financial or personal SMS history of a user.**

Even if your app has a valid SMS exception (Section 3.1), all SMS and Call Log use case exceptions must comply with the Spyware Policy, which prohibits exfiltration of data not related to policy-compliant functionality.

#### Severity Determination — Two Independent Gates

The policy creates **two independent compliance gates**. Final severity = the worst of the two.

The auditor's job is to judge the **OUTCOME** against the policy text, not to prescribe **HOW** the developer must achieve it. Whether the developer uses sender allow-lists, keyword filters, server-side re-filtering, or any other mechanism is the developer's choice. The auditor's only question is: *does the actually-exfiltrated set include non-financial or personal SMS?*

**Gate 1 — Permissions Declaration (right to use READ_SMS)**

Source: [SMS and Call Log Permission Policy](https://support.google.com/googleplay/android-developer/answer/10208820). Approved exception use cases include:
- (viii) SMS-based financial transactions and related activity including OTP and fraud detection
- (ix) Track, budget, manage SMS-based financial transactions and related account verification

| Declaration Status | Severity |
|--------------------|----------|
| Approved for use case (viii)/(ix) | passes Gate 1 |
| Pending, not submitted, or rejected | BLOCKER — no right to use READ_SMS |
| Status unknown to auditor | NEEDS_CONFIRMATION |

**Gate 2 — Spyware Cat.4 (actually-exfiltrated content)**

Policy text (verbatim): *"Personal loans or budgeting apps exfiltrating or sharing non-financial or personal SMS history of a user."*

Source: [Understanding Google Play's Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000).

| Actual SMS content transmitted | Severity |
|--------------------------------|----------|
| Includes any non-financial or personal SMS | BLOCKER |
| Only financial SMS — developer has provided evidence | passes Gate 2 |
| Cannot be determined from static code review | NEEDS_CONFIRMATION |

**Final verdict** = the more severe of Gate 1 and Gate 2. Approval at Gate 1 does **not** exempt Gate 2. A code path that uploads all SMS to a server is a Gate 2 BLOCKER even if Permissions Declaration is approved.

**To leave NEEDS_CONFIRMATION at Gate 2**, the developer must provide evidence that the actually-exfiltrated set contains no non-financial or personal SMS. The auditor does not specify what evidence is sufficient — that depends on the developer's implementation. The auditor only judges whether the evidence proves the outcome.

#### Background Context (Informational — NOT Severity Inputs)

The following facts inform long-term compliance risk but **must not be used as audit severity inputs**. The verdict is governed only by the two gates above.

- Approval rates for SMS Permissions Declaration have been reported as low for loan/lending apps in the 2024–2026 cycle.
- Industry direction is to phase out SMS scraping for credit scoring. See [Lendsqr analysis (Feb 2026)](https://blog.lendsqr.com/does-android-still-allow-lenders-to-scrap-sms-from-phones-for-scoring/) and [TrustDecision compliance guide](https://trustdecision.com/articles/financial-service-apps-meet-new-google-sms-compliance-mandates).
- Uploading full SMS body content (versus metadata only) reportedly receives heightened review.

These observations are useful when advising the developer on direction. They do **not** raise the audit severity of an otherwise compliant implementation.

#### Detection Patterns (Auditor Tooling — NOT Compliance Recipe)

The grep patterns below help the auditor **locate** SMS code paths to investigate. Presence of any pattern is not itself a violation, and absence does not prove compliance. The verdict is determined by the two gates above, applied to the actual transmission outcome.

**Code audit — SMS exfiltration check**:
```bash
# Find ALL SMS query code:
grep -rn "Telephony.Sms\|content://sms\|SmsMessage" --include="*.kt"

# Check what SMS fields are read:
grep -rn "Telephony.Sms\.\(BODY\|ADDRESS\|DATE\|READ\|STATUS\|TYPE\)" --include="*.kt"

# Check SMS filtering logic — is filtering applied before or after query?
grep -rn "LIKE\|like\|contains\|matches\|filter" --include="*.kt" | grep -i "sms\|message\|body"

# Check what is uploaded — does the request include SMS body text?
grep -rn "SP_BODY\|sms_body\|message_body\|body" --include="*.kt" | grep -i "add\|put\|property"

# Check for incremental/continuous SMS collection:
grep -rn "SMS_SUCCESS_TIME\|last.*sms.*time\|sms.*timestamp" --include="*.kt"
```

**SMS audit questions**:
- Does the app access SMS data that is unrelated to its policy-compliant core functionality?
- Is SMS data collected in the background when the user is not engaging with the app?
- Is any non-financial or personal SMS content transmitted to a server?
- For loan/budgeting apps: is any SMS history shared that is not directly related to financial transactions?
- Is SMS filtering applied at SQL query level (WHERE clause) or only after full inbox read?
- Does the app upload full SMS body content, or only metadata (sender, date, type)?

**Policy Requirements (BLOCKER if violated)**:
- [ ] Permissions Declaration Form submitted and approved for SMS exception use case (Gate 1)
- [ ] No non-financial or personal SMS data transmitted or shared (Gate 2)
- [ ] No SMS data collected in the background unrelated to policy-compliant functionality
- [ ] SMS data is not shared with third-party analytics or advertising services for purposes outside the approved use case

**Engineering Suggestions (auditor's preference — NOT policy requirements)**:

The auditor MUST NOT use these as severity inputs. They are options the developer may evaluate when designing their own compliance approach. Listing or omitting them does not change the verdict at Gate 1 or Gate 2.

- (Suggested) Apply filtering at SQL query level (WHERE clause) rather than post-query, to reduce the read surface
- (Suggested) Upload SMS metadata (sender, date, type) instead of full body content where the use case allows
- (Suggested) Use SMS Retriever API for OTP scenarios instead of READ_SMS
- (Suggested) Minimize retention period and total volume of stored SMS data

> **⚠ MAINTENANCE NOTE — SMS Policy Freshness Check**
>
> This section's two-gate severity model (Gate 1 Permissions Declaration / Gate 2 Spyware Cat.4 outcome) is derived from Google Play's
> [SMS or Call Log permission groups](https://support.google.com/googleplay/android-developer/answer/10208820),
> [Spyware policy](https://support.google.com/googleplay/android-developer/answer/9888380), and
> [Understanding Spyware policy](https://support.google.com/googleplay/android-developer/answer/14745000).
>
> **Every time this skill is updated, you MUST re-check the above three URLs for policy changes.**
> Key items to verify:
> 1. Whether the temporary exception use cases (viii)/(ix) for financial apps still exist (Gate 1)
> 2. Whether the "non-financial or personal SMS" wording in the Spyware policy has changed (Gate 2 boundary)
> 3. Whether the Permissions Declaration Form process has changed (Gate 1 evidence requirements)
> 4. Whether Google has begun prescribing implementation mechanisms (sender lists, filtering, metadata-only) — currently the policy is silent on HOW, and the auditor must remain silent too
> 5. Google Play [policy announcements page](https://support.google.com/googleplay/android-developer/announcements/13412212) for any SMS-related updates
>
> Last verified: 2026-05-18

### 11.5 Spyware Policy Checklist

- [ ] Prominent disclosure shown before ALL data collection (Category 1)
- [ ] User can decline and still use basic functionality (Category 1)
- [ ] No data transmitted before consent (Category 2)
- [ ] No background data uploads without notification (Category 2)
- [ ] All collected data is necessary for stated functionality (Category 3)
- [ ] No personal SMS content exfiltration (Category 4)
- [ ] Data collection stops when user revokes permissions
- [ ] Data deletion mechanism exists and works
