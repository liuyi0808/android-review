# Consent Flow & Data Transparency Audit

## Table of Contents
- [13.1 Consent Flow Sequence Audit](#131-consent-flow-sequence-audit)
- [13.2 Permission Denial Handling](#132-permission-denial-handling)
- [13.3 Prominent Disclosure Content Requirements](#133-prominent-disclosure-content-requirements)
- [13.4 Third-Party Data Sharing Transparency](#134-third-party-data-sharing-transparency)

---

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
