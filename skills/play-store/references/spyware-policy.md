# Spyware & User Data Policy (CRITICAL)

## Table of Contents
- [11.1 Category 1: Data Collection Without Adequate Notice](#111-category-1-data-collection-without-adequate-notice)
- [11.2 Category 2: Covert Data Transmission](#112-category-2-covert-data-transmission)
- [11.3 Category 3: Data Collection Unrelated to App Functionality](#113-category-3-data-collection-unrelated-to-app-functionality)
- [11.4 Category 4: Personal SMS/Call Log Exfiltration](#114-category-4-personal-smscall-log-exfiltration-critical-for-loan-apps)
- [11.5 Spyware Policy Checklist](#115-spyware-policy-checklist)

---

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
