# Google Play 2026 Policy Requirements

This document collects every Google Play policy requirement relevant to a privacy policy audit.

---

## Table of Contents

1. [User Data Policy](#1-user-data-policy)
2. [Prominent Disclosure and Consent Requirements](#2-prominent-disclosure-and-consent-requirements)
3. [Privacy Policy Requirements](#3-privacy-policy-requirements)
4. [Account Deletion Requirements](#4-account-deletion-requirements)
5. [Personal Loans Policy](#5-personal-loans-policy)
6. [Spyware Policy](#6-spyware-policy)
7. [Deceptive Behavior Policy](#7-deceptive-behavior-policy)
8. [Misrepresentation Policy](#8-misrepresentation-policy)
9. [Device and Network Abuse Policy](#9-device-and-network-abuse-policy)
10. [SMS / Call Log Permissions Policy](#10-sms--call-log-permissions-policy)
11. [QUERY_ALL_PACKAGES Permission Policy](#11-query_all_packages-permission-policy)
12. [Photo and Video Permissions Policy](#12-photo-and-video-permissions-policy)
13. [Sensitive Information Access Permissions and APIs Policy](#13-sensitive-information-access-permissions-and-apis-policy)
14. [Financial Features Declaration](#14-financial-features-declaration)
15. [Data Safety Form Requirements](#15-data-safety-form-requirements)
16. [Foreground Service Requirements](#16-foreground-service-requirements)
17. [July 2026 Policy Update](#17-july-2026-policy-update)

---

## 1. User Data Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/10144311

### 1.1 Core transparency principle

Developers must be transparent about how they handle user data, including:
- Data access
- Data collection
- Data use
- Data handling
- Data sharing

### 1.2 Definition of personal and sensitive user data

The following are treated as sensitive data:
- Personally identifiable information (PII)
- Financial and payment information
- Authentication information (passwords, tokens, etc.)
- Address book / contacts
- Device location
- SMS and call-related data
- Health data and Health Connect data
- Inventory of other apps on the device
- Microphone, camera, and other sensitive device data

### 1.3 Core requirements

| Requirement | Notes |
|-------------|-------|
| Data minimization | Collect and use only the data required for the app's functionality |
| No selling | Personal and sensitive user data must not be sold |
| Secure transmission | Data must be handled securely with modern cryptography (e.g. HTTPS) |
| Runtime permissions | A runtime permission must be requested before accessing data protected by an Android permission |

### 1.4 Persistent device identifier restrictions

Persistent identifiers such as IMEI, IMSI, and SIM serial number must not be linked to other user data, except for:
- Telephony features tied to SIM identity
- Enterprise device management apps using device owner mode

---

## 2. Prominent Disclosure and Consent Requirements

**Policy source**: https://support.google.com/googleplay/android-developer/answer/11150561

### 2.1 When prominent disclosure is required

1. When the user could not reasonably expect the data collection
2. When using permissions and sensitive APIs that require prominent disclosure:
   - Accessibility Service APIs
   - Background Location Permission
   - Package (App) Visibility Permission

### 2.2 Disclosure content requirements

| Element | Notes |
|---------|-------|
| Why | Describe why the app needs the capability and its core purpose |
| What | If data is collected, disclose every data type involved |
| How | Describe how the data is used in the core functionality |
| Clarity | All text must be clear and understandable at a 13-year-old reading level |

### 2.3 Disclosure format requirements

- Must be shown in-app before the permission is requested
- Must not live only in the store listing or on a website
- Must offer an option to decline consent
- The app should remain usable after the user denies the permission

### 2.4 Consent requirements

- Consent must come from an "affirmative user action" (e.g. tapping accept, ticking a checkbox)
- Navigating away from the disclosure must not be treated as consent
- Auto-dismissing messages must not be used to obtain consent

---

## 3. Privacy Policy Requirements

**Policy source**: https://support.google.com/googleplay/android-developer/answer/10144311

### 3.1 Required content

| Requirement | Notes |
|-------------|-------|
| Developer information | Developer/company name and privacy contact details |
| App identification | The app name must be referenced in the privacy policy |
| Data access | State which personal and sensitive user data the app accesses |
| Data collection | State which data the app collects |
| Data use | State how that data is used |
| Data sharing | State which third parties the data is shared with |
| Data security | Describe secure data handling procedures |
| Data retention | Describe the data retention policy |
| Data deletion | Describe the data deletion policy |

### 3.2 Format and accessibility requirements

| Requirement | Notes |
|-------------|-------|
| Clearly labeled | Must be explicitly labeled "Privacy Policy" |
| Publicly accessible | Must be hosted at an active, publicly accessible URL |
| Not a PDF | Must not be in PDF format |
| No geo-fencing | Must not be restricted by geo-fencing |
| Non-editable | Must not be editable by users |

---

## 4. Account Deletion Requirements

**Policy source**: https://support.google.com/googleplay/android-developer/answer/13327111

### 4.1 Core requirements

If the app allows account creation, it must:
- Provide an in-app account deletion path
- Provide a web-based deletion option (for users who uninstalled the app)
- Delete all associated user data when the account is deleted

### 4.2 Scope of data deletion

Account deletion must delete:
- Personal and sensitive user data
- Personally identifiable information
- Financial and payment information
- Authentication information
- Contact data
- Device location
- SMS and call-related data
- Health data
- Every data type marked as "collected" in the Data Safety section

### 4.3 Data retention disclosure

If some data must be retained for the reasons below, the privacy policy must say so explicitly:
- Security
- Fraud prevention
- Regulatory compliance

### 4.4 Prohibited practices

- Freezing/deactivating an account does not satisfy the deletion requirement
- Users must not be required to reinstall the app in order to delete their account

---

## 5. Personal Loans Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/9876821

### 5.1 App category requirement

A personal loan app must set its **App Category to "Finance"** in Play Console.

### 5.2 Information that must be disclosed in the app metadata

| Must disclose | Notes |
|---------------|-------|
| Repayment period | Minimum and maximum repayment period |
| Maximum APR | Interest rate plus fees and other costs |
| Representative total loan cost | A representative example including principal and all applicable fees |
| Privacy policy | Full disclosure of access to, collection, use, and sharing of personal and sensitive user data |

### 5.3 Banned permissions (core restriction)

The following permissions are **completely banned** for personal loan apps, loan lead-generation apps, loan support tools, and EWA apps:

| Permission | Notes |
|------------|-------|
| `READ_EXTERNAL_STORAGE` | Read external storage |
| `READ_MEDIA_IMAGES` | Read media images |
| `READ_CONTACTS` | Read contacts |
| `ACCESS_FINE_LOCATION` | Precise location |
| `READ_PHONE_NUMBERS` | Read phone numbers |
| `READ_MEDIA_VIDEO` | Read media video |
| `QUERY_ALL_PACKAGES` | Query all installed packages |
| `WRITE_EXTERNAL_STORAGE` | Write external storage |
| `READ_SMS` | Read SMS |
| `READ_CALL_LOG` | Read call log |

### 5.4 Repayment period restriction

Personal loans that require full repayment within **60 days or less** of disbursement are **prohibited**.

### 5.5 United States specific requirements

- **APR cap**: the APR must not reach or exceed **36%**
- **Disclosure requirement**: the maximum APR must be calculated and displayed consistently with the Truth in Lending Act (TILA)

### 5.6 Country / region specific requirements

| Country / region | Requirement |
|------------------|-------------|
| India | Only licensed apps on the RBI "Digital lending apps (DLAs)" list may be submitted |
| Indonesia | A valid copy of the OJK license must be submitted |
| Philippines | A PSEC registration number and CA number are required and must be disclosed in the description |
| Nigeria | Registration under the FCCPC digital lending framework must be completed, with an approval letter |
| Kenya | A CBK license is required; only digital credit providers published on the CBK website are accepted |
| Pakistan | Each NBFC may publish only one DLA; short-term loan apps are banned |
| Thailand | An interest rate ≥15% requires a BoT or MoF license |

---

## 6. Spyware Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/9888380

### 6.1 Definition

Spyware is "malicious apps, code, or behavior that collect, exfiltrate, or share user or device data unrelated to policy-compliant functionality."

### 6.2 Violating behavior

- Recording audio or phone calls
- Stealing data from other apps
- Using malicious third-party SDKs that transmit data in ways users do not expect

### 6.3 Examples of spyware violations

| Violation type | Example |
|----------------|---------|
| SDK-related | Using an SDK to transmit audio or call recordings unrelated to compliant functionality |
| Information theft | Stealing information from other apps' notifications |
| Unauthorized transmission | Transmitting the contact list, photos the app does not own, user email, call log, or SMS history |
| Financial app specific | A loan app exfiltrating the user's non-financial SMS history |

### 6.4 Key compliance requirements

1. **Restrict data access**: keep data access within the scope of policy-compliant functionality
2. **Protect user privacy**: the app and its SDKs must comply with the User Data policy
3. **Prevent surveillance behavior**: anything that could be seen as surveilling the user may be flagged as spyware
4. **Review SDKs**: periodically review the data handling behavior of every SDK embedded in the app

---

## 7. Deceptive Behavior Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/17006354

### 7.1 Core principle

Apps must be honest and transparent, must never mislead users, and must not enable dishonest behavior. All metadata must accurately reflect the app's functionality.

### 7.2 Misleading claims are prohibited

- Misrepresenting app functionality in the description, title, icon, or screenshots
- Claiming functionality that is not achievable (e.g. an insect repellent app), even when labeled a "prank"
- Miscategorizing the app
- Deceptive content about elections or voting processes
- Falsely claiming government affiliation or endorsement
- Using "Official" in the title without appropriate permission/authorization

### 7.3 Deceptive device settings changes

- Changing device settings requires explicit user knowledge and consent
- Every change must be easily reversible by the user
- Settings must not be modified for third-party or advertising purposes
- Users must not be misled or incentivized into removing/disabling third-party apps

### 7.4 Enabling dishonest behavior is prohibited

- Apps that generate fake IDs, passports, diplomas, social security numbers, credit cards, or bank accounts
- Impersonating other apps/websites to phish users' personal information
- Displaying unverified personal information about people who did not consent

### 7.5 Behavior transparency requirements

- App functionality must be reasonably clear to users
- No hidden, dormant, or undocumented functionality
- No techniques used to evade app review
- The app must behave consistently for ordinary users and for reviewers

---

## 8. Misrepresentation Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/9888689

### 8.1 Prohibited behavior

- Impersonating any person or organization
- Concealing or misrepresenting ownership or primary purpose
- Engaging in coordinated activity to mislead users
- Misrepresenting or concealing the country of origin while targeting users in other countries
- Coordinated concealment of developer or app identity in political or social-issue contexts

### 8.2 Compliance requirements

- Fill in the developer name, organization, and contact information in the account clearly and accurately
- Ensure the app title, icon, and description truthfully reflect functionality and purpose
- State the country of origin and location truthfully in the developer profile

---

## 9. Device and Network Abuse Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/16559646

### 9.1 Prohibited behavior

- Blocking or interfering with the display of ads by other apps
- Cheating tools that affect gameplay of other apps
- Providing hacking services, software, hardware, or instructions for bypassing security protections
- Accessing or using an API or service in violation of its terms
- Non-allowlisted apps attempting to bypass system power management
- Providing proxy services to third parties (unless it is the app's primary core functionality)
- Downloading executable code (dex, JAR, .so files, etc.) from outside Google Play
- Installing other apps on the device without user consent
- Linking to or facilitating the distribution or installation of malware

### 9.2 FLAG_SECURE requirement

Every app must respect other apps' FLAG_SECURE declaration and must not create workarounds.

---

## 10. SMS / Call Log Permissions Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/10208820

### 10.1 Core principle

These permissions may only be accessed by apps that fall into an "allowed use" category, and only to support the app's **core functionality**.

### 10.2 Allowed use cases (must be registered as a default handler)

| Default handler type | Allowed permissions |
|----------------------|---------------------|
| Default SMS handler | READ_SMS, RECEIVE_MMS, RECEIVE_SMS, RECEIVE_WAP_PUSH, SEND_SMS, WRITE_SMS |
| Default phone handler | SEND_SMS, PROCESS_OUTGOING_CALLS, READ_CALL_LOG, WRITE_CALL_LOG |
| Default assistant handler | READ_SMS, RECEIVE_MMS, RECEIVE_SMS, READ_CALL_LOG |

### 10.3 Exceptions (non-default handlers may apply)

- Anti-SMS phishing
- User backup and restore
- Caller ID / spam identification and blocking
- Connected device companion apps (smartwatches, cars, etc.)
- Cross-device synchronization
- Device automation
- Enterprise archiving / CRM / device management
- In-car hands-free use
- Emergency safety alerts
- Proxy calling
- SMS-based financial transactions
- SMS-based money management

### 10.4 Prohibited use cases

| Prohibited use | Notes |
|----------------|-------|
| SMS OTP verification | Use the SMS Retriever API instead |
| Content sharing or invitations | Use a Share Intent instead |
| Social graph and personality analysis | Completely prohibited |
| Call recording | Completely prohibited |
| Device performance optimization | Completely prohibited |
| Family / device location | Completely prohibited |
| Research (e.g. SMS-based market research) | Completely prohibited |
| Remote control of the user's device | Completely prohibited |
| Any transmission leading to the sale of data | Completely prohibited |

### 10.5 Upcoming changes

**From January 27, 2027**: READ_CALL_LOG may no longer be used for "account verification via phone call"; use the Digital Credentials API or the SMS Retriever API instead.

---

## 11. QUERY_ALL_PACKAGES Permission Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/10158779

### 11.1 Allowed use cases

Limited to apps whose core functionality requires discovering every installed app on the device:
- Device search apps
- Antivirus apps
- File managers
- Browsers

### 11.2 Temporary exceptions

| App type | Condition |
|----------|-----------|
| Real-money gambling apps | Broad package visibility needed to comply with geo-fencing regulations |
| Financial transaction apps | Visibility granted for security purposes only |

**Important**: under the Personal Loans policy, any use for personal loans, credit, or facilitating access to personal loans **does not qualify for this exception**.

### 11.3 Prohibited use cases

- Use not directly related to the core purpose
- Acquiring data for sales purposes
- Use for analytics or advertising monetization
- Use when the required task can be accomplished by a less broad method

---

## 12. Photo and Video Permissions Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/14115180

### 12.1 Core requirement

Apps targeting Android 13+ (API 33+) may request `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` only when the Android Photo Picker is insufficient for the core functionality.

### 12.2 Allowed scenarios

- Gallery-type apps (core functionality is managing all photos/videos)
- Apps whose needs the Photo Picker technically cannot meet

### 12.3 Compliance requirements

- **Deadline**: full compliance required by May 28, 2025
- A declaration must be submitted in Play Console explaining why the Photo Picker is insufficient
- An alternative (e.g. the system picker) must be offered when the user denies the permission

---

## 13. Sensitive Information Access Permissions and APIs Policy

**Policy source**: https://support.google.com/googleplay/android-developer/answer/16585319

### 13.1 General requirements

- Permission requests must be meaningful to the user
- Request only the permissions required for the current feature
- The feature must be clearly advertised in the Play Store listing
- Personal or sensitive data must never be sold or shared to facilitate a sale
- The user's decision to deny a permission must be respected

### 13.2 Special requirements per permission type

| Permission type | Special requirements |
|-----------------|----------------------|
| Location permissions | Request the minimum scope needed; must not be requested solely for advertising or analytics |
| MANAGE_EXTERNAL_STORAGE | Only for access critical to app functionality; must pass access review |
| Accessibility APIs | Must not be used to change user settings, bypass privacy controls, or record calls; requires a declaration and a demo video |
| Request install packages permission | Core functionality must include sending/receiving app packages; must not be used for self-updates |
| VPN Service | Must encrypt data; must not collect sensitive data without disclosure and consent |
| Health Connect | Health/fitness/medical use cases only; must not be sold or used for advertising or credit assessment |

---

## 14. Financial Features Declaration

**Policy source**: https://support.google.com/googleplay/android-developer/answer/13849271

### 14.1 Apps that must complete the declaration

- Every app published on Google Play
- Including apps on closed testing, open testing, and production tracks
- Even apps with no financial features must complete the form and declare "no financial features"

### 14.2 Financial features that must be declared

| Category | Features |
|----------|----------|
| Banking and lending | Personal loan direct lender, loan lead generation, payday loans, banking, lines of credit, earned wage access, microfinance |
| Payments and transfers | Mobile payments and digital wallets, money transfer services |
| Purchase agreements | Reward points, buy now pay later |
| Trading and funds | Crypto wallets/exchanges, NFTs, stock trading, crowdfunding |
| Support services | Credit monitoring, financial advice, insurance |

### 14.3 Extra requirements for personal loan apps

If the app includes personal loan related features, it must:
1. Provide information about the relationship with partner lenders
2. Upload valid license evidence for the relevant region

---

## 15. Data Safety Form Requirements

**Policy source**: https://support.google.com/googleplay/android-developer/answer/10787469

### 15.1 Data types that must be disclosed

| Category | Data types |
|----------|-----------|
| Location | Approximate location (≥3 km²), precise location (<3 km²) |
| Personal info | Name, email, user ID, address, phone number, race, political/religious beliefs, sexual orientation |
| Financial | Payment info, purchase history, credit score |
| Health and fitness | Health info, fitness info |
| Messages | Emails, SMS, other in-app messages |
| Photos / videos | Photos, videos |
| Audio | Voice recordings, music files |
| Files and docs | Files and documents |
| Calendar | Calendar events |
| Contacts | Contact information |
| App activity | Interactions, in-app search, installed apps, user-generated content |
| Web browsing | Browsing history |
| App performance | Crash logs, diagnostics |
| Device ID | Device or other identifiers |

### 15.2 Data purpose declaration

The reason for collecting/sharing data must be declared:
- App functionality
- Analytics
- Developer communications
- Advertising or marketing
- Fraud prevention, security, compliance
- Personalization
- Account management

### 15.3 Relationship with the privacy policy

- The Data Safety form and the privacy policy must be consistent
- A privacy policy link is required to complete the form
- Misrepresentation can result in removal of the app from Google Play

---

## 16. Foreground Service Requirements

**Policy source**: https://support.google.com/googleplay/android-developer/answer/13392821

### 16.1 Android 14+ requirements

Before using a foreground service you must:
1. Declare the foreground service type in the manifest
2. Declare and request the corresponding foreground service permission

### 16.2 Foreground service types and use cases

| Type | Allowed use cases |
|------|-------------------|
| TYPE_CAMERA | Background camera stream (e.g. multitasking during video chat) |
| TYPE_CONNECTED_DEVICE | Data transfer with external devices over Bluetooth, NFC, USB, etc. |
| TYPE_DATA_SYNC | User-initiated backup/restore, upload/download |
| TYPE_HEALTH | Health data sync for fitness apps |
| TYPE_LOCATION | User-initiated location sharing, navigation |
| TYPE_MEDIA_PLAYBACK | Background audio/video playback |
| TYPE_MEDIA_PROJECTION | Screen projection/recording |
| TYPE_MICROPHONE | Background audio capture |
| TYPE_PHONE_CALL | Cellular/VoIP calling functionality |
| TYPE_SPECIAL_USE | Limited scenarios (subject to review) |

---

## 17. July 2026 Policy Update

**Policy source**: https://support.google.com/googleplay/android-developer/answer/17134731

### 17.1 Effective date

Starting July 15, 2026, developers have at least 30 days to update their apps.

### 17.2 Main updates

| Update | Notes |
|--------|-------|
| SMS / call log permissions | READ_CALL_LOG may no longer be used for account verification |
| User Data policy | Clarified to apply to third-party AI integrations |
| Target API level | The latest requirement must be met by August 31, 2026 |

### 17.3 Policy clarifications

- Earned wage access (EWA) app requirements redefined
- Added guidance on precise/approximate location disclosure in the Data Safety section
- Content rating: unrated apps explicitly not allowed

---

## Reference Links

### Core policies

| Policy | Link |
|--------|------|
| User Data policy | https://support.google.com/googleplay/android-developer/answer/10144311 |
| Personal Loans policy | https://support.google.com/googleplay/android-developer/answer/9876821 |
| Account deletion requirements | https://support.google.com/googleplay/android-developer/answer/13327111 |
| Prominent disclosure requirements | https://support.google.com/googleplay/android-developer/answer/11150561 |
| Deceptive behavior | https://support.google.com/googleplay/android-developer/answer/17006354 |
| Misrepresentation | https://support.google.com/googleplay/android-developer/answer/9888689 |
| Device and network abuse | https://support.google.com/googleplay/android-developer/answer/16559646 |

### Permission-related policies

| Policy | Link |
|--------|------|
| Sensitive information access permissions and APIs | https://support.google.com/googleplay/android-developer/answer/16585319 |
| SMS / call log permissions | https://support.google.com/googleplay/android-developer/answer/10208820 |
| QUERY_ALL_PACKAGES permission | https://support.google.com/googleplay/android-developer/answer/10158779 |
| Photo and video permissions | https://support.google.com/googleplay/android-developer/answer/14115180 |
| Foreground service requirements | https://support.google.com/googleplay/android-developer/answer/13392821 |

### Security and malware policies

| Policy | Link |
|--------|------|
| Spyware policy | https://support.google.com/googleplay/android-developer/answer/9888380 |
| Understanding the spyware policy | https://support.google.com/googleplay/android-developer/answer/14745000 |

### Declarations and forms

| Policy | Link |
|--------|------|
| Financial Features Declaration | https://support.google.com/googleplay/android-developer/answer/13849271 |
| Data Safety form guide | https://support.google.com/googleplay/android-developer/answer/10787469 |

### Policy announcements

| Announcement | Link |
|--------------|------|
| July 15, 2026 policy announcement | https://support.google.com/googleplay/android-developer/answer/17134731 |
| April 15, 2026 policy announcement | https://support.google.com/googleplay/android-developer/answer/16926792 |
| Policy deadlines | https://support.google.com/googleplay/android-developer/table/12921780 |
| Policy announcement index | https://support.google.com/googleplay/android-developer/announcements/13412212 |
