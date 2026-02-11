---
name: play-store
description: Google Play Store submission and compliance checklist for Android apps, with special focus on financial/loan apps. Covers build config, permissions, Data Safety, Financial Features Declaration, Personal Loan policy, sensitive permission restrictions, spyware policy, deceptive behavior, device abuse, consent flow transparency, data transmission audit, loan app harassment policy, account deletion, developer verification, and code-level audit. Updated for 2025-2026 policy cycle.
---

# Google Play Compliance & Launch Checklist

Comprehensive pre-submission audit and compliance verification for Google Play Store publishing. Includes 2025-2026 policy updates with special sections for **financial/loan apps**.

**Policy effective date**: January 28, 2026 (unless otherwise stated per section).

## Pre-Submission Audit Process

Evaluate the app against ALL categories below. For detailed rules per category, load the corresponding reference file. Output findings as:

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

## Reference Guide — Load on Demand

Each reference file contains the full policy details, code audit commands, and checklists for its topic. **Read the relevant file when auditing that category.**

| # | Reference File | Sections | When to Load |
|---|---------------|----------|-------------|
| 1 | [references/build-and-signing.md](references/build-and-signing.md) | 1-2 | Auditing build.gradle, targetSdk, AAB, R8, signing, log guards |
| 2 | [references/permissions.md](references/permissions.md) | 3 | Auditing AndroidManifest permissions, SMS/Call Log, QUERY_ALL_PACKAGES, photo/video, location, FGS types, alarms |
| 3 | [references/financial-declaration.md](references/financial-declaration.md) | 4 | Play Console Financial Features Declaration, loan app requirements, country-specific rules |
| 4 | [references/data-privacy.md](references/data-privacy.md) | 5-7 | Data Safety form, SDK data audit, account deletion, privacy policy |
| 5 | [references/store-listing.md](references/store-listing.md) | 8-9 | Store listing assets, metadata quality, content rating, IARC |
| 6 | [references/deceptive-behavior.md](references/deceptive-behavior.md) | 10 | #1 rejection reason — misleading claims, system UI mimicry, undisclosed data collection, disclosure-vs-reality gap, hidden functionality, ads |
| 7 | [references/spyware-policy.md](references/spyware-policy.md) | 11 | Spyware 4 categories — inadequate notice, covert transmission, unrelated collection, SMS exfiltration |
| 8 | [references/device-abuse.md](references/device-abuse.md) | 12 | Device settings modification, accessibility abuse, app interference, network abuse |
| 9 | [references/consent-flow.md](references/consent-flow.md) | 13 | End-to-end consent flow audit, permission denial handling, disclosure content requirements |
| 10 | [references/loan-harassment.md](references/loan-harassment.md) | 14 | Loan app harassment, predatory lending, prohibited data for credit scoring |
| 11 | [references/deployment.md](references/deployment.md) | 15-17 | Developer verification (2026), testing tracks, post-launch monitoring, Play Vitals |
| 12 | [references/code-audit.md](references/code-audit.md) | 18 | All grep/code audit commands — manifest, code, build config, spyware, device abuse, harassment |

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
- [ ] EWA apps: fees transparent ($1–$5 or 1–5%), no debt creation, no credit bureau reporting

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
- [ ] No autonomous action initiation/planning/execution via Accessibility API (Oct 2025 update)
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
| Restricted permission misuse | READ_SMS without exception, or READ_CONTACTS in loan app | Submit exception form, or remove prohibited permissions | BLOCKER |
| Over-permissioning | Unnecessary permissions | Remove unused permissions from manifest | BLOCKER |
| No account deletion | Missing in-app or web deletion | Implement account + data deletion flow | BLOCKER |
| Minimum functionality | App is essentially a WebView wrapper | Add native functionality beyond WebView | BLOCKER |
| Spyware - no consent | Data collected before user consent shown | Move SDK init after consent dialog | BLOCKER |
| Spyware - SMS exfiltration | Personal SMS content uploaded to server | Remove SMS body upload or use SMS Retriever API | BLOCKER |
| Spyware - covert transmission | SDKs transmit data before consent dialog | Delay SDK initialization until after consent | BLOCKER |
| Consent decline ineffective | Decline/Cancel does same as Accept | Make decline genuinely prevent data collection | BLOCKER |
| Disclosure gap | Collected data not in consent dialog | Update consent dialog to list all data types | BLOCKER |
| Loan harassment | Contact access used for debt collection | Remove READ_CONTACTS, block collection use | BLOCKER |
| Predatory lending | Loan terms < 60 days or hidden fees | Ensure minimum 60 day terms, disclose all fees | BLOCKER |
| Hidden functionality | DexClassLoader or remote code execution | Remove dynamic code loading | BLOCKER |
| Missing FGS type | Foreground service without type | Add foregroundServiceType in manifest | WARNING |
| Photo permission without declaration | READ_MEDIA_IMAGES without form | Submit declaration or switch to Photo Picker | WARNING |

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

---

*For OWASP-level code security audit, see the `security-audit` skill.*
