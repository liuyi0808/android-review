---
name: play-store
description: Google Play Store submission and compliance checklist for Android apps, with special focus on financial/loan apps. Covers build config, permissions (including Contacts Permissions, Contact Picker, location button, Geofence API), Data Safety, Financial Features Declaration, Personal Loan policy, sensitive permission restrictions, spyware policy, deceptive behavior, device abuse, consent flow transparency, data transmission audit, loan app harassment policy, intellectual property (trademark/copyright/counterfeit), restricted content, account deletion, developer verification, and code-level audit. Updated for 2025-2026 policy cycle including April 15, 2026 announcement.
---

# Google Play Compliance & Launch Checklist

Comprehensive pre-submission audit and compliance verification for Google Play Store publishing. Includes 2025-2026 policy updates with special sections for **financial/loan apps**.

**Policy effective date**: March 4, 2026 (unless otherwise stated per section).

## Execution Contract (MUST read before starting)

This skill has **14 reference files**. A full audit MUST load all 14.
"Progressive disclosure" does NOT mean "skip files you think you know" — it means load each file before you make a claim against it, then cite the specific section.

### The Five Rules

1. **All 14 references MUST be loaded.** If a reference does not apply to the target app (e.g., App has no store listing assets yet), the auditor MUST explicitly mark it "Not Applicable" with a one-line reason in the Coverage Report. Silent skipping is forbidden.

2. **Parallel execution is the default.** Spawn 5 Task subagents in a single message so they run concurrently. See "Parallel Execution Pattern" below for the exact grouping. The main agent merges findings and produces the final report.

3. **Every finding MUST cite its reference.** Output format is not optional — see "Output Format" below. A finding without both `Reference:` and `Policy Source:` is invalid and must be rejected.

4. **The Reference Coverage Report is mandatory.** Before the audit report is complete, emit a Coverage table with 14 rows. No Coverage table → the report is incomplete.

5. **No conclusions from memory.** If you cannot cite the reference file section you relied on, you do not have the finding. "I remember Personal Loans policy says X" is not acceptable — you must have actually loaded `loan-harassment.md` in this session before claiming a Personal Loans violation.

---

## Parallel Execution Pattern

Launch **5 Task subagents in parallel** (a single assistant message with 5 tool calls). Each subagent owns a group of reference files and returns findings in the Output Format.

| Subagent | Reference Files to Load | Audit Focus |
|----------|------------------------|-------------|
| **A — Build & Code Basics** | `build-and-signing.md`, `permissions.md`, `code-audit.md` | `build.gradle`, `AndroidManifest.xml`, release config, grep patterns |
| **B — Money & Privacy** | `financial-declaration.md`, `data-privacy.md`, `loan-harassment.md` | Play Console financial declaration, SDK list, Data Safety alignment, lending data use, harassment patterns |
| **C — Spyware, Consent & Deception** | `spyware-policy.md`, `consent-flow.md`, `deceptive-behavior.md` | Startup sequence, SDK init order, consent dialog, disclosure-vs-reality, hidden functionality |
| **D — Abuse, Content & IP** | `device-abuse.md`, `restricted-content.md`, `intellectual-property.md` | Accessibility service, FLAG_SECURE, app strings, logos/icons, brand misuse |
| **E — Listing & Deployment** | `store-listing.md`, `deployment.md` | Store listing assets, testing tracks, Play Vitals, developer verification |

**Subagent prompt template** (use this when dispatching each subagent):

```
You are subagent {A|B|C|D|E} of a parallel Google Play compliance audit.

Your reference files: {list}
Your audit scope: {focus}
Target app path: {absolute path}

Instructions:
1. Read EACH of your reference files in full before auditing.
2. For each finding, produce the full Output Format block including
   Reference: <file>#<anchor> and Policy Source: <official URL>.
3. If a reference does not apply to the target app, return:
   "Not Applicable: <one-line reason>" for that file.
4. Return ALL findings as a single markdown list when done.
```

**Main agent responsibilities after subagents return**:
1. Merge all 5 subagent outputs.
2. Deduplicate overlapping findings (same file:line + same policy).
3. Sort by severity: BLOCKER > WARNING > INFO.
4. Produce the Reference Coverage Report.
5. Emit the final report in the order: Summary → Findings → Coverage Report → Launch Day Checklist.

---

## Pre-Submission Audit Process

Output each finding as a full block with all six fields. **All fields are mandatory** — none may be omitted:

```
[GP-XXXXX] status: BLOCKER | WARNING | INFO
  Category: <section number, e.g. "3.1.4" or "IP.2">
  Finding: <what is missing or wrong>
  Evidence: <file:line or manifest entry>
  Reference: <reference file>#<section anchor>
  Policy Source: <official Google Play policy URL>
  Fix: <concrete action to resolve>
  Deadline: <policy enforcement date if applicable, else "Active">
```

**Example (correct form)**:

```
[GP-00123] status: BLOCKER
  Category: 3.1.4 — Personal Loan Apps additional restrictions
  Finding: READ_CONTACTS declared in manifest of a personal loan app
  Evidence: app/src/main/AndroidManifest.xml:8
  Reference: permissions.md#314-personal-loan-apps--additional-restrictions
  Policy Source: https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans
  Fix: Remove READ_CONTACTS from manifest (or add tools:node="remove" for transitive SDK declarations)
  Deadline: Active
```

**A finding without both `Reference:` and `Policy Source:` is invalid** — the main agent MUST reject such findings before emitting the report. If the subagent could not identify the reference anchor, the finding was not grounded in the reference file and should be dropped.

Severity definitions:
- **BLOCKER**: App will be rejected or removed. Must fix before submission.
- **WARNING**: May trigger review delay or future enforcement. Fix recommended.
- **INFO**: Best practice improvement. No immediate enforcement risk.

---

## Reference File Index (all 14 must be loaded for a full audit)

Each reference file contains the full policy details, code audit commands, and checklists for its topic. Per the Execution Contract, an auditor MUST load all 14 files during a full audit and MUST explicitly mark any file as "Not Applicable" in the Coverage Report if they skip it.

| # | Reference File | Subagent Group | Sections | Scope |
|---|---------------|----------------|----------|-------|
| 1 | [references/build-and-signing.md](references/build-and-signing.md) | A | 1-2 | `build.gradle`, targetSdk, AAB, R8, signing, log guards |
| 2 | [references/permissions.md](references/permissions.md) | A | 3 | Manifest permissions, SMS/Call Log, QUERY_ALL_PACKAGES, photo/video, location (incl. location button), FGS types, alarms, Contacts Permissions (Contact Picker) |
| 3 | [references/financial-declaration.md](references/financial-declaration.md) | B | 4 | Play Console Financial Features Declaration, loan app requirements, country-specific rules |
| 4 | [references/data-privacy.md](references/data-privacy.md) | B | 5-7 | Data Safety form, SDK data audit, account deletion, privacy policy |
| 5 | [references/store-listing.md](references/store-listing.md) | E | 8-9 | Store listing assets, metadata quality, content rating, IARC |
| 6 | [references/deceptive-behavior.md](references/deceptive-behavior.md) | C | 10 | Misleading claims, system UI mimicry, undisclosed data collection, disclosure-vs-reality gap, hidden functionality, ads |
| 7 | [references/spyware-policy.md](references/spyware-policy.md) | C | 11 | Spyware 4 categories — inadequate notice, covert transmission, unrelated collection, SMS exfiltration |
| 8 | [references/device-abuse.md](references/device-abuse.md) | D | 12 | Device settings modification, accessibility abuse, app interference, network abuse |
| 9 | [references/consent-flow.md](references/consent-flow.md) | C | 13 | End-to-end consent flow audit, permission denial handling, disclosure content requirements |
| 10 | [references/loan-harassment.md](references/loan-harassment.md) | B | 14 | Loan app harassment, predatory lending, prohibited data for credit scoring |
| 11 | [references/deployment.md](references/deployment.md) | E | 15-17 | Developer verification (2026), testing tracks, post-launch monitoring, Play Vitals |
| 12 | [references/code-audit.md](references/code-audit.md) | A | 18 | Grep/code audit commands — manifest, code, build config, spyware, device abuse, harassment |
| 13 | [references/intellectual-property.md](references/intellectual-property.md) | D | IP | Trademark, copyright, counterfeit, financial-app brand-misuse risks |
| 14 | [references/restricted-content.md](references/restricted-content.md) | D | RC | Restricted content categories applicable to all apps; loan-app surfaces (strings, notifications, support scripts) |

---

## Reference Coverage Report (mandatory output)

Emit this table once, at the end of the audit report, immediately before the Launch Day Checklist. Fill in every row.

```markdown
## Reference Coverage Report

| # | Reference | Loaded | Findings | Notes |
|---|-----------|--------|----------|-------|
| 1 | build-and-signing.md | ✅ | <N> | — |
| 2 | permissions.md | ✅ | <N> | — |
| 3 | financial-declaration.md | ✅ | <N> | — |
| 4 | data-privacy.md | ✅ | <N> | — |
| 5 | store-listing.md | ✅ / ⏭ Not Applicable | <N> | <reason if N/A> |
| 6 | deceptive-behavior.md | ✅ | <N> | — |
| 7 | spyware-policy.md | ✅ | <N> | — |
| 8 | device-abuse.md | ✅ | <N> | — |
| 9 | consent-flow.md | ✅ | <N> | — |
| 10 | loan-harassment.md | ✅ | <N> | — |
| 11 | deployment.md | ✅ | <N> | — |
| 12 | code-audit.md | ✅ | — | Used as grep pattern source |
| 13 | intellectual-property.md | ✅ | <N> | — |
| 14 | restricted-content.md | ✅ | <N> | — |

Coverage: <M>/14 loaded, <K> marked Not Applicable
Total findings: <T> (<B> BLOCKER, <W> WARNING, <I> INFO)
```

**Loaded column values**:
- `✅` — Reference was read and findings (or a clean result) were produced.
- `⏭ Not Applicable` — Reference was read, but scope does not apply. Must include reason in Notes.
- `❌ Skipped` — Any row with this value means the audit is incomplete and the report must be treated as a draft, not a decision.

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
- [ ] `READ_CONTACTS`: if declared, Contact Picker evaluated and documented as insufficient (effective Oct 28, 2026, Android 17+)
- [ ] One-time precise location uses `onlyForLocationButton` flag; persistent precise location has Play Developer Declaration
- [ ] Geofencing uses Geofence API, not a foreground service
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
- [ ] Pricing & distribution set (free/paid, target countries, in-app purchases declared)
- [ ] All Permissions Declaration Forms submitted

## Financial App Specific
- [ ] App category = "Finance"
- [ ] Loan terms in app description (APR, repayment, representative cost)
- [ ] Licensing documents uploaded for target countries
- [ ] No short-term loans (< 60 days)
- [ ] No access to photos/contacts for lending decisions — applies to loan apps, accessory loan/credit apps (calculators, guides), and EWA apps (SMS governed by Section 3.1 exception policy)
- [ ] EWA apps: fees transparent ($1–$5 or 1–5%), no debt creation, no credit bureau reporting

## Spyware & Privacy (Section 11)
- [ ] Prominent disclosure shown BEFORE any data collection or SDK init
- [ ] User can DECLINE data collection and still use basic functionality
- [ ] No SDK transmits data before user consent
- [ ] No non-financial or personal SMS history exfiltrated or shared (loan/budgeting apps)
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
- [ ] App respects FLAG_SECURE set by other apps (no screen capture of secure content)

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
- [ ] No trademark / copyright / counterfeit issues (IP section) — no unauthorized bank, lender, or regulator logos
- [ ] No restricted content in strings, notifications, or store listing (RC section) — especially no harassing / shaming language in collection notifications

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
| Spyware - SMS exfiltration | Non-financial or personal SMS history exfiltrated or shared | Remove non-policy-compliant SMS data transmission; SMS Retriever API only replaces OTP use case | BLOCKER |
| Spyware - covert transmission | SDKs transmit data before consent dialog | Delay SDK initialization until after consent | BLOCKER |
| Consent decline ineffective | Decline/Cancel does same as Accept | Make decline genuinely prevent data collection | BLOCKER |
| Disclosure gap | Collected data not in consent dialog | Update consent dialog to list all data types | BLOCKER |
| Loan harassment | Contact access used for debt collection | Remove READ_CONTACTS, block collection use | BLOCKER |
| Predatory lending | Loan terms < 60 days or hidden fees | Ensure minimum 60 day terms, disclose all fees | BLOCKER |
| Hidden functionality | DexClassLoader or remote code execution | Remove dynamic code loading | BLOCKER |
| Broad contacts access without justification | `READ_CONTACTS` declared without Contact Picker evaluation (Android 17+) | Switch to Android Contact Picker, or submit Play Developer Declaration for broad access | BLOCKER (Oct 28, 2026) |
| Precise location without location button | Fine location for one-time use but no `onlyForLocationButton` flag and no persistent-location declaration | Add `onlyForLocationButton` for discrete use, or submit Play Developer Declaration for persistent access | WARNING (May 15, 2026) |
| Geofencing via foreground service | Location FGS used as geofencing transport | Use Geofence API directly; remove FGS for geofencing | WARNING (May 15, 2026) |
| Missing FGS type | Foreground service without type | Add foregroundServiceType in manifest | WARNING |
| Photo permission without declaration | READ_MEDIA_IMAGES without form | Submit declaration or switch to Photo Picker | WARNING |
| Trademark / copyright infringement | Unauthorized bank, lender, or regulator logo in icon, screenshots, or store listing | Replace with owned or licensed assets; remove brand references | BLOCKER |
| Counterfeit / impersonation | App mimics an established bank or lender | Rebrand so the app does not cause source confusion | BLOCKER |
| Harassing language in strings | Threatening / shaming copy in collection notifications | Rewrite to neutral, factual language | BLOCKER |

---

## 21. Key Policy Deadlines (2025-2026)

| Date | Requirement | Impact |
|------|------------|--------|
| May 28, 2025 | Photo/Video permissions full compliance | App removal if non-compliant |
| May 28, 2025 | Line of credit apps must comply with Personal Loan policy | BLOCKER |
| August 31, 2025 | Target API 35 for new apps and updates | Submission blocked |
| November 1, 2025 | API 35 extension deadline | No more extensions |
| January 1, 2026 | Age Signals API data use restriction (announced Nov 19, 2025) | Policy enforcement |
| January 28, 2026 | Accessibility API: autonomous action prohibition enforced | Policy enforcement |
| January 28, 2026 | India personal loan apps: must be on government approved list | Policy enforcement |
| March 4, 2026 | Updated Developer Program Policies effective | Full enforcement |
| March 4, 2026 | Thailand loan app listing requirements (service provider, rates, fees) | Existing apps |
| May 15, 2026 | Location button (`onlyForLocationButton`) / Geofencing removed from FGS / Photo & Video clarifications (announced April 15, 2026) | Policy enforcement |
| October 27, 2026 | Play Console pre-review checks for contacts and location permissions go live | Tooling |
| October 28, 2026 | Contacts Permissions policy enforcement (Android 17+ / API 37+) — Contact Picker required for non-broad access | Policy enforcement |
| July 2024+ | Financial/health/VPN/government developers must register as Organization | Rolling out |

---

## References

- [Google Play Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/16810878?hl=en)
- [Policy Deadlines](https://support.google.com/googleplay/android-developer/table/12921780?hl=en)
- [Policy Announcements](https://support.google.com/googleplay/android-developer/announcements/13412212?hl=en)
- [Financial Features Declaration](https://support.google.com/googleplay/android-developer/answer/13849271?hl=en) (may redirect — see Financial Services Policy for current guidance)
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
- [Policy Announcement: April 15, 2026](https://support.google.com/googleplay/android-developer/answer/16926792?hl=en)
- [Understanding restricted permissions with minimum scope alternatives](https://support.google.com/googleplay/android-developer/answer/16935362?hl=en)
- [Contact Picker: Privacy-First Contact Sharing — Android Developers Blog](https://android-developers.googleblog.com/2026/03/contact-picker-privacy-first-contact.html)
- [Redefining Location Privacy — Android Developers Blog](https://android-developers.googleblog.com/2026/03/location-privacy.html)
- [Android Developer - Default Handlers](https://developer.android.com/guide/topics/permissions/default-handlers)
- [Spyware Policy](https://support.google.com/googleplay/android-developer/answer/9888380?hl=en#spyware)
- [Understanding Spyware Policy](https://support.google.com/googleplay/android-developer/answer/14745000?hl=en)
- [Deceptive Behavior Policy](https://support.google.com/googleplay/android-developer/answer/16680223?hl=en)
- [Device and Network Abuse Policy](https://support.google.com/googleplay/android-developer/answer/16559646?hl=en)
- [User Data Policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Prominent Disclosure Requirements](https://support.google.com/googleplay/android-developer/answer/11150561?hl=en)
- [Personal Loans Policy](https://support.google.com/googleplay/android-developer/answer/9876821?hl=en#personal-loans)
- [Stalkerware Policy](https://support.google.com/googleplay/android-developer/answer/10065570?hl=en)
- [Intellectual Property Policy](https://support.google.com/googleplay/android-developer/answer/9888072?hl=en)
- [Google Play Developer Program Policy — Restricted Content](https://support.google.com/googleplay/android-developer/answer/16810878?hl=en)

---

*For OWASP-level code security audit, see the `security-audit` skill.*
