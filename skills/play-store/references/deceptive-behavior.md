# Deceptive Behavior Policy (Top Rejection Reason)

## Table of Contents
- [10.1 Misleading Claims & Metadata Mismatch](#101-misleading-claims--metadata-mismatch)
- [10.2 System UI Mimicry](#102-system-ui-mimicry)
- [10.3 Undisclosed Data Collection](#103-undisclosed-data-collection)
- [10.4 Disclosure-vs-Reality Gap](#104-disclosure-vs-reality-gap)
- [10.5 Hidden Functionality](#105-hidden-functionality)
- [10.6 Permissions Policy](#106-permissions-policy)
- [10.7 Ads Compliance](#107-ads-compliance-if-applicable)
- [10.8 Families Policy](#108-families-policy-if-targeting-children)
- [10.9 User-Generated Content](#109-user-generated-content-if-applicable)

---

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
