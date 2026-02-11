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

#### 13.3.1 Common Prominent Disclosure Violations (Google Examples)

Google has published specific scenarios that constitute Prominent Disclosure violations. Use this list during audit to catch common failures:

**Violation scenarios (from Google policy documentation)**:

1. **Undisclosed location purpose**: App collects location data but does not explain which feature uses it, or fails to disclose background location usage.
2. **Installed apps / contacts not treated as sensitive**: App accesses the list of installed applications or the user's contact list but does not treat this data as personal/sensitive data requiring prominent disclosure.
3. **Screen recording not treated as sensitive**: App records the user's screen but does not treat the recording as personal/sensitive data in its disclosure.
4. **Background restricted-permission usage without consent**: App uses restricted permissions in the background (for tracking, research, or marketing) without adequate disclosure and affirmative consent.
5. **Disclosure buried in ToS / privacy policy**: Data collection is mentioned only within Terms of Service or Privacy Policy, rather than in a standalone in-app Prominent Disclosure.
6. **Disclosure outside the app**: Disclosure appears only in the app's Play Store description or external website, not within the app itself before data collection.
7. **No pre-request in-app disclosure**: Runtime permission request is shown without a preceding in-app disclosure that explains why the permission is needed.

**Background location — special Prominent Disclosure requirements**:

The disclosure text **must explicitly contain all three elements**:
- The word **"location"** (or equivalent in app language)
- The word **"background"** (or equivalent)
- The phrase **"when the app is closed"** (or equivalent indicating closed/not-in-use state)

Example of compliant disclosure:
> "This app collects your **location** in the **background**, even **when the app is closed**, to provide real-time delivery tracking."

**SDK data collection — Prominent Disclosure obligations**:

If a third-party SDK integrated in the app **defaults to collecting sensitive data** (device identifiers, location, etc.):
- The app is still responsible for disclosing this collection in its Prominent Disclosure
- If Google flags SDK-initiated collection, the developer must provide compliance evidence **within 2 weeks**
- "I didn't know the SDK collected that" is not a valid defense

**Auditor guidance — detecting "form-compliant but substance-violating" disclosures**:

Watch for these patterns that pass surface inspection but violate the spirit of the policy:

| Pattern | Problem | How to Detect |
|---------|---------|--------------|
| Data types listed but no purpose | Disclosure says "we collect location" but never says why | Check each data type has a corresponding "for [purpose]" clause |
| Disclosure buried in settings | Disclosure exists but is in a deep settings menu, not in the normal app flow | Trace the first-launch flow — disclosure must appear before any data leaves the device |
| Disclosure text doesn't match reality | Disclosure mentions "fraud prevention" but code also uploads data for marketing | Compare disclosure text against actual data transmission code (Section 13.1 audit) |
| Generic catch-all language | "We may collect various device information" instead of specific data types | Flag any disclosure that uses "may", "various", "information", or "data" without specifics |
| Pre-checked consent | Consent checkbox is checked by default | Verify consent requires affirmative user action |

**Extended audit checklist**:
- [ ] Disclosure is standalone (not inside ToS or privacy policy)
- [ ] Disclosure is shown in-app (not only in store listing or website)
- [ ] Disclosure appears before ANY data collection or SDK initialization
- [ ] Each data type has a stated purpose (not just a list of data types)
- [ ] Background location disclosure contains "location" + "background" + "when the app is closed"
- [ ] All SDK-initiated data collection is covered by the disclosure
- [ ] Disclosure text matches actual data collection behavior (no disclosure-vs-reality gap)
- [ ] No generic catch-all language ("various information", "device data", etc.)
- [ ] Consent requires affirmative action (no pre-checked boxes)

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
