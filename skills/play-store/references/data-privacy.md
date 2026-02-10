# Data Safety, Account Deletion & Privacy Policy

## Table of Contents
- [5. Data Safety Section](#5-data-safety-section-mandatory)
  - [5.1 When Required](#51-when-required)
  - [5.2 What to Declare](#52-what-to-declare)
  - [5.3 For Each Data Type](#53-for-each-data-type-declare)
  - [5.4 SDK Audit](#54-sdk-audit-critical)
  - [5.5 Data Deletion Questions](#55-data-deletion-questions-mandatory)
  - [5.6 Checklist](#56-checklist)
- [6. Account Deletion Requirement](#6-account-deletion-requirement-mandatory)
  - [6.1 Policy](#61-policy)
  - [6.2 What Must Be Deleted](#62-what-must-be-deleted)
  - [6.3 Exceptions](#63-exceptions)
  - [6.4 What Does NOT Qualify](#64-what-does-not-qualify)
  - [6.5 Play Console Requirements](#65-play-console-requirements)
- [7. Privacy Policy](#7-privacy-policy-mandatory)
  - [7.1 Requirements](#71-requirements)
  - [7.2 Content Must Include](#72-content-must-include)
  - [7.3 Financial App Privacy Policy Additions](#73-financial-app-privacy-policy-additions)
  - [7.4 Anti-Patterns](#74-anti-patterns)

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
