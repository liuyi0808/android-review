---
name: play-store
description: Google Play submission and compliance audit for personal loan apps targeting Africa and Latin America. Covers organization account verification, market-specific licensing, loan restrictions, data and permissions, reviewer access, and general Play publishing requirements.
---

# Google Play Compliance & Launch Checklist

Default scope: **personal loan apps distributed in Africa and Latin America**. Apply global Play rules and assess country-specific rules for each actual target country. Expand geographic scope only when the user explicitly requests it. An app's package-wide Data Safety declaration still covers all applicable versions distributed on Play.

**Policy baseline**: October 29, 2026 announcement. Determine enforcement dates per applicable rule from the official Policy Deadlines; the announcement date is not the enforcement date.

### Loan-first decision order

1. Identify the product category and exact countries using Play Console distribution settings, the listing, actual flows and Financial Features Declaration. Record the submitted variant, effective target SDK, and artifact evidence. If the country list is unknown, flag the market assessment as `NEEDS_CONFIRMATION` and continue evaluating global requirements. See `financial-declaration.md` §4.4.
2. Apply the Financial Services prohibitions first (see `permissions.md` §3.1.4). A confirmed, effective loan-banned permission is a `BLOCKER` without a declaration path. A source-only hit, unknown category or unresolved manifest removal is not conclusive.
3. For other restricted permissions, map the runtime flow and data destinations to the actual core use and Play Console declaration. Determine whether alternatives are required or sufficient. Assess restrictions on purpose and data handling separately, even if a permission declaration is approved.
4. For each dated rule record `Effective` or `Upcoming` and its enforcement date. Use the planned submission date if supplied, otherwise the audit date. Upcoming-only issues go in a separate readiness section, not present violations. A currently effective loan, User Data, or Deceptive Behavior violation is still reported under that rule.
5. Check new feature-specific rules (AppFunctions, local network, contact management, eligibility-based subscriptions) only when relevant. Record missing Console/backend or artifact evidence as `NEEDS_CONFIRMATION`; never treat a keyword hit or a clean scan as proof of a verdict.
6. Verify the loan app's **Organization** developer account and identity in Play Console (`deployment.md` §§15.1–15.2). Confirmed ownership by a Personal account is a `BLOCKER` for the covered loan app. Missing account evidence is `NEEDS_CONFIRMATION`. Personal developer account production-access criteria are out of scope. Assess app registration, trader status, reviewer access, memory, DEX optimization and zero-tap restoration separately.

## Execution Contract (MUST read before starting)

This skill has **14 reference files**. A full audit MUST load all 14.
"Progressive disclosure" does NOT mean "skip files you think you know" — it means load each file before you make a claim against it, then cite the specific section.

### The Six Rules

1. **All 14 references MUST be loaded.** If a reference does not apply to the target app (e.g., App has no store listing assets yet), the auditor MUST explicitly mark it "Not Applicable" with a one-line reason in the Coverage Report. Silent skipping is forbidden.

2. **Parallel execution is the default.** Spawn 5 Task subagents in a single message so they run concurrently. See "Parallel Execution Pattern" below for the exact grouping. The main agent merges findings and produces the final report.

3. **Every finding MUST cite its reference.** Output format is not optional — see "Output Format" below. A finding without both `Reference:` and `Policy Source:` is invalid and must be rejected.

4. **The Reference Coverage Report is mandatory.** Before the audit report is complete, emit a Coverage table with 14 rows. No Coverage table → the report is incomplete.

5. **Read the policy, not just the announcement.** Load the relevant local reference and verify the current official requirement, including linked enforcement dates, tables, FAQs or exceptions that affect the decision. Record scope, effective date, required action, evidence and enforcement consequence. An item labeled a reminder can still carry an account or publishing requirement. If the source does not specify an exact date or action, do not invent one; identify what still needs confirmation in Console.

6. **Judge outcome against policy. Never prescribe implementation as policy.** Every finding must answer two structural questions, with both answers visible in the Output Format:

   - **Declaration gate**: Does Google provide a declaration channel for this policy (Permissions Declaration, Data Safety, Financial Declaration)? If yes and the developer's declaration status is unknown to the auditor, severity is **NEEDS_CONFIRMATION** — never BLOCKER/WARNING. If no channel applies (e.g., a confirmed loan-banned permission or proven review manipulation), judge against the policy and verified evidence.

   - **Outcome vs. implementation**: The `Required by policy:` field must contain verbatim or near-verbatim policy text — if you cannot quote it, you do not have a policy requirement. Any engineering preference (sender allow-lists, keyword filters, server-side checks, SP-key guards, specific APIs like SMS Retriever) goes in `Suggested implementation:` and must be explicitly marked "non-policy, auditor's suggestion only." Code existence alone is not a violation — the auditor judges what is actually exfiltrated, transmitted, or done, not what the code might do under some interpretation.

   **Why**: Past audits failed by packaging engineering preferences (e.g., "you must add a sender whitelist" or "OTP must use SMS Retriever API") as policy demands, and by judging code patterns (e.g., `READ_SMS + uploadInfo`) as violations without checking declaration status or actual transmission outcome. The Output Format below makes both gates structurally mandatory — a finding that fails either gate is invalid and must be rejected by the main agent.

---

## Parallel Execution Pattern

Launch **5 Task subagents in parallel** (a single assistant message with 5 tool calls). Each subagent owns a group of reference files and returns findings in the Output Format.

| Subagent | Reference Files to Load | Audit Focus |
|----------|------------------------|-------------|
| **A — Build & Code Basics** | `build-and-signing.md`, `permissions.md`, `code-audit.md` | `build.gradle`, `AndroidManifest.xml`, release config, grep patterns |
| **B — Money & Privacy** | `financial-declaration.md`, `data-privacy.md`, `loan-harassment.md` | Play Console financial declaration, SDK list, Data Safety alignment, lending data use, harassment patterns |
| **C — Spyware, Consent & Deception** | `spyware-policy.md`, `consent-flow.md`, `deceptive-behavior.md` | Startup sequence, SDK init order, consent dialog, disclosure-vs-reality, hidden functionality |
| **D — Abuse, Content & IP** | `device-abuse.md`, `restricted-content.md`, `intellectual-property.md` | Accessibility service, FLAG_SECURE, app strings, logos/icons, brand misuse |
| **E — Listing & Deployment** | `store-listing.md`, `deployment.md` | Listing, testing tracks, developer verification, trader declaration, Play Vitals, bundle quality and sign-in restoration |

**Subagent prompt template** (use this when dispatching each subagent):

```
You are subagent {A|B|C|D|E} of a parallel Google Play compliance audit.

Your reference files: {list}
Your audit scope: {focus}
Target app path: {absolute path}

Instructions:
1. Read EACH of your reference files in full before auditing.
2. For each finding, produce the full Output Format block including
   ALL ELEVEN mandatory fields:
     status, Category, Finding, Evidence, Reference, Policy Source,
     Declaration Channel, Declaration Status,
     Required by policy, Suggested implementation, Deadline.
3. Apply Rule 6 (Six Rules):
   - If the policy has a declaration channel and you cannot confirm
     the developer's declaration status, status = NEEDS_CONFIRMATION
     (never BLOCKER/WARNING).
   - Apply the loan-first decision order; keep upcoming-only findings out of current severity totals.
   - `Required by policy:` must be a verbatim or near-verbatim quote
     from the policy URL. If you cannot quote it, do not write the
     finding — you do not have a policy requirement.
   - Any implementation mechanism (sender allow-lists, specific APIs,
     SP-key names, server-side filtering, etc.) goes ONLY in
     `Suggested implementation:` prefixed "non-policy, auditor's
     suggestion only" — never in Required by policy or Finding.
4. If a reference does not apply to the target app, return:
   "Not Applicable: <one-line reason>" for that file.
5. Return ALL findings as a single markdown list when done.
```

**Main agent responsibilities after subagents return**:
1. Merge all 5 subagent outputs.
2. Deduplicate overlapping findings (same file:line + same policy).
3. **Validate every finding against Rule 6 hard constraints**:
   - Missing `Reference:` or `Policy Source:` → drop.
   - `Declaration Channel ≠ None` AND `Declaration Status = Unknown` AND `status ≠ NEEDS_CONFIRMATION` → downgrade to NEEDS_CONFIRMATION.
   - `Required by policy:` contains prescriptive implementation language not in policy text → move to `Suggested implementation:` before emitting.
   - `Required by policy:` cannot be traced to a quote at the cited URL → downgrade to INFO or drop.
4. Sort by severity: BLOCKER > WARNING > INFO. **NEEDS_CONFIRMATION findings are listed in a separate section** after INFO, never tallied with the others.
5. Produce the Reference Coverage Report.
6. Emit the final report in this order:
   Summary → Findings (BLOCKER → WARNING → INFO) → Pending Confirmation (NEEDS_CONFIRMATION) → Upcoming Policy Readiness → Coverage Report → Launch Day Checklist.
   In the Coverage Report, always include the deployment evidence table below.
7. **Write the final report to a markdown file** in the current working directory: `play-store-audit-report.md`. The file must contain the complete audit report in markdown format.

---

## Pre-Submission Audit Process

Output each finding as a full block with all eleven fields. **All fields are mandatory** — none may be omitted:

```
[GP-XXXXX] status: BLOCKER | WARNING | INFO | NEEDS_CONFIRMATION
  Category: <section number, e.g. "3.1.4" or "IP.2">
  Finding: <factual observation — what the code/manifest/listing actually does>
  Evidence: <file:line — describe ACTUAL behavior (e.g. "uploads full SMS body via POST /api/sync"), not just code existence (e.g. "calls uploadInfo()")>
  Reference: <reference file>#<section anchor>
  Policy Source: <official Google Play policy URL>
  Declaration Channel: <Permissions Declaration | Data Safety | Financial Declaration | Trader Status | Console Exemption Request | None>
  Declaration Status: <Confirmed | Pending | Unknown | Not Applicable>
  Required by policy: <verbatim or near-verbatim policy text + URL — if you cannot quote it, the requirement is not from policy>
  Suggested implementation: <engineering option(s), explicitly prefixed "non-policy, auditor's suggestion only" — or "None">
  Deadline: <policy enforcement date if applicable, else "Active">
```

**Hard constraints (main agent MUST enforce before emitting the report)**:

1. **Missing reference** — A finding without both `Reference:` and `Policy Source:` is invalid. Drop it.
2. **Declaration gate consistency** — If `Declaration Channel ≠ None` AND `Declaration Status = Unknown`, then `status:` MUST be `NEEDS_CONFIRMATION`. Findings that violate this are invalid; downgrade or drop.
3. **Policy-quote consistency** — If `Required by policy:` does not contain a quote from a policy URL (or paraphrases beyond recognition), the policy basis is fabricated. Drop or downgrade to `INFO`.
4. **Prescription leakage** — If `Required by policy:` contains specific implementation mechanisms (sender allow-lists, particular APIs, SP-key names, server-side filter requirements) that do not appear in the policy text, move that content to `Suggested implementation:` before emitting.

**Example A — absolute prohibition, no declaration channel**:

```
[GP-00101] status: BLOCKER
  Category: 3.1.4 — Financial Services loan permission ban
  Finding: The submitted personal-loan artifact declares android.permission.READ_CONTACTS.
  Evidence:
    - Store listing and loan application flow confirm personal lending.
    - Submitted artifact's manifest contains the effective uses-permission entry.
  Reference: permissions.md#314-personal-loan-apps--additional-restrictions
  Policy Source: https://support.google.com/googleplay/android-developer/answer/9876821
  Declaration Channel: None
  Declaration Status: Not Applicable
  Required by policy: Covered apps may not use the listed permissions, including READ_CONTACTS.
  Suggested implementation: non-policy, auditor's suggestion only: locate the manifest contributor and remove the declaration from the submitted variant.
  Deadline: Active
```

**Example B — declaration-gated policy, status unknown**:

```
[GP-00102] status: NEEDS_CONFIRMATION
  Category: 11.4 — Spyware Cat.4 (Personal SMS exfiltration)
  Finding: App reads SMS via Telephony.Sms.CONTENT_URI and transmits filtered rows to a backend; auditor cannot determine from static review whether the actually-transmitted set excludes non-financial or personal SMS.
  Evidence: app/src/main/java/.../SmsHelper.kt:42-88 — query + LIKE filter + POST /api/sms/sync (body field included)
  Reference: spyware-policy.md#114-category-4-personal-smscall-log-exfiltration-critical-for-loan-apps
  Policy Source: https://support.google.com/googleplay/android-developer/answer/14745000
  Declaration Channel: Permissions Declaration
  Declaration Status: Unknown
  Required by policy: "Personal loans or budgeting apps exfiltrating or sharing non-financial or personal SMS history of a user." (Spyware policy — URL above). All SMS use cases also require Permissions Declaration approval per SMS/Call Log policy.
  Suggested implementation: None — auditor judges only the outcome (whether non-financial/personal SMS leaves the device). The developer chooses the mechanism.
  Deadline: Active
  Resolution requires: (a) Permissions Declaration status (Confirmed/Pending/Rejected), and (b) evidence that the actually-transmitted SMS set contains no non-financial or personal records.
```

Severity definitions:
- **BLOCKER**: App will be rejected or removed. Auditor has direct evidence of policy violation. Must fix before submission.
- **WARNING**: May trigger review delay or future enforcement. Fix recommended.
- **INFO**: Best practice improvement. No immediate enforcement risk.
- **NEEDS_CONFIRMATION**: Code triggers a declaration-gated policy, but the declaration status or actual outcome cannot be determined from static review. The auditor MUST NOT escalate to BLOCKER/WARNING without (a) declaration evidence from the developer/Play Console, and (b) evidence that the actual runtime outcome meets the policy. Reported in a **separate section** of the final report, never mixed into BLOCKER/WARNING tallies.

---

## Reference File Index (all 14 must be loaded for a full audit)

Each reference file contains the full policy details, code audit commands, and checklists for its topic. Per the Execution Contract, an auditor MUST load all 14 files during a full audit and MUST explicitly mark any file as "Not Applicable" in the Coverage Report if they skip it.

| # | Reference File | Subagent Group | Sections | Scope |
|---|---------------|----------------|----------|-------|
| 1 | [references/build-and-signing.md](references/build-and-signing.md) | A | 1-2 | Effective target API, submitted AAB, billing, 16 KB compatibility, R8, signing, log guards |
| 2 | [references/permissions.md](references/permissions.md) | A | 3 | Manifest permissions, SMS/Call Log, QUERY_ALL_PACKAGES, photo/video, location (incl. location button), FGS types, alarms, Contacts Permissions (Contact Picker) |
| 3 | [references/financial-declaration.md](references/financial-declaration.md) | B | 4 | Play Console Financial Features Declaration, loan app requirements, country-specific rules |
| 4 | [references/data-privacy.md](references/data-privacy.md) | B | 5-7 | Data Safety form, SDK data audit, account deletion, privacy policy |
| 5 | [references/store-listing.md](references/store-listing.md) | E | 8-9 | Store listing assets, metadata quality, content rating, IARC |
| 6 | [references/deceptive-behavior.md](references/deceptive-behavior.md) | C | 10 | Misleading claims, system UI mimicry, undisclosed data collection, disclosure-vs-reality gap, hidden functionality, ads |
| 7 | [references/spyware-policy.md](references/spyware-policy.md) | C | 11 | Spyware 4 categories — inadequate notice, covert transmission, unrelated collection, SMS exfiltration |
| 8 | [references/device-abuse.md](references/device-abuse.md) | D | 12 | Device settings modification, accessibility abuse, app interference, network abuse |
| 9 | [references/consent-flow.md](references/consent-flow.md) | C | 13 | End-to-end consent flow audit, permission denial handling, disclosure content requirements |
| 10 | [references/loan-harassment.md](references/loan-harassment.md) | B | 14 | Loan app harassment, predatory lending, prohibited data for credit scoring |
| 11 | [references/deployment.md](references/deployment.md) | E | 15-17 | Developer verification, trader status, testing tracks, and technical quality requirements |
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
Pending confirmation: <N> NEEDS_CONFIRMATION (not part of the verdict; require developer evidence to resolve)
```

**Loaded column values**:
- `✅` — Reference was read and findings (or a clean result) were produced.
- `⏭ Not Applicable` — Reference was read, but scope does not apply. Must include reason in Notes.
- `❌ Skipped` — Any row with this value means the audit is incomplete and the report must be treated as a draft, not a decision.

**Mandatory deployment evidence**: Add these rows under reference 11 even if none is a current finding. Record the applicable deadline, evidence, status and next action. Use `Not Applicable` only with a verified scope reason. An inaccessible Console or unavailable Vitals history is `NEEDS_CONFIRMATION`.

| Check | Evidence to record |
|-------|--------------------|
| Organization account | App's owning Play Console account type, organization verification status and linkage to the licence holder where applicable |
| Reviewer access | App access instructions and replay of restricted flows with supplied test credentials where applicable |
| Trader status | Account declaration, any required per-app confirmation, trader self-certification and terms link, outstanding notices and due dates |
| Memory | Play Vitals period, cohort, P90, RAM tier, app state and any threshold warning |
| DEX optimization | App bundle version, DEX size and all three optimization percentages |
| Zero-tap sign-in restoration | Device migration test evidence, qualifying existing integration or applicable Console exemption status |

---

## 19. Launch Day Checklist (Final)

```markdown
## Pre-Submit
- [ ] Mobile new app/update targets API 36+; assess the separate API 35+ discoverability threshold for existing apps (§1.1)
- [ ] AAB format (not APK)
- [ ] For submissions using Play Billing, verify the resolved library version against the applicable deadline (§1.3)
- [ ] Check the submitted bundle for 16 KB compatibility, including packaged SDK native libraries, and record readiness for the February 1, 2027 update block (§1.5)
- [ ] R8/ProGuard enabled, resources shrunk
- [ ] Submitted version code is unused, above the version it replaces and at most 2,100,000,000 (§1.4)
- [ ] ProGuard mapping saved
- [ ] SMS/Call Log permissions: either removed, or Permissions Declaration Form submitted with exception approval
- [ ] Personal loan apps: no prohibited permissions (contacts, photos, phone numbers, fine location)
- [ ] For covered loan apps, verify the eight banned permissions against the submitted variant. A picker, location-button flag, or Console declaration does not waive these bans.
- [ ] Where allowed and applicable, check Contact Picker, minimum location scope, the location button flag in the effective manifest and the precise-location declaration, and the actual purpose of location FGS (January 27, 2027; permissions.md §§3.4, 3.6, 3.9).
- [ ] When present, check all-files access (including SDK/partner purpose), and Accessibility approval, designation and disclosure; record readiness for AppFunctions, LAN access and contact management (permissions.md §§3.11–3.13).
- [ ] All foreground services have declared types

## Play Console
- [ ] App is owned by a verified Organization developer account (§§15.1–15.2)
- [ ] App signing configured (Play App Signing)
- [ ] Trader status submitted at account level; for traders, verify app-level confirmation, self-certification and terms links (§15.4)
- [ ] Store listing complete (icon, screenshots, descriptions)
- [ ] Financial Features Declaration completed for applicable tracks, even when there are no financial features (§4.1)
- [ ] Content rating questionnaire completed
- [ ] Data Safety covers applicable versions of this package distributed on Play and their actual SDK data flows (§5.2)
- [ ] Privacy policy URL active and linked
- [ ] If account creation is supported, verify in-app and web deletion requests plus server and applicable service-provider handling (§6)
- [ ] Contact email configured
- [ ] Pricing & distribution set (free/paid, target countries, in-app purchases declared)
- [ ] All Permissions Declaration Forms submitted

## Financial App Specific
- [ ] App category = "Finance"
- [ ] Personal loan terms in app description (APR, repayment, representative cost); apply the separate EWA disclosure checklist where relevant (§4.5.1)
- [ ] Confirm exact African and Latin American target countries, lender/facilitator role, applicable licences and Console evidence (§4.4)
- [ ] No personal loan requires full repayment in 60 days or less from issuance, unless a documented exception applies
- [ ] No access to photos/contacts for lending decisions — applies to loan apps, accessory loan/credit apps (calculators, guides), and EWA apps (SMS governed by Section 3.1 exception policy)
- [ ] EWA apps: verify earned-wage scope, repayment conditions, all fees and a representative total-cost example (§4.5.1)

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
- [ ] Reviewer and production-user loan flows compared for equivalent eligible accounts, locales and product conditions (§10.5).

## Device Abuse (Section 12)
- [ ] No device settings modification
- [ ] No accessibility service abuse; verify applicable Console approval and any required disclosure and consent
- [ ] Distinguish prohibited autonomous behavior from deterministic rules; verify any accessibility-tool exemption and its core assistive purpose (§12.2)
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
- [ ] If account creation is supported, verify accessible deletion paths and associated data handling (§6)
- [ ] Privacy policy matches Data Safety declarations
- [ ] No trademark / copyright / counterfeit issues (IP section) — no unauthorized bank, lender, or regulator logos
- [ ] No restricted content in strings, notifications, or store listing (RC section) — especially no harassing / shaming language in collection notifications

## Testing
- [ ] Internal testing track verified
- [ ] Check the testing track actually used for this release
- [ ] For restricted flows, replay Play Console App access instructions with reusable test credentials (§16.3)
- [ ] Pre-launch report reviewed (no critical issues)
- [ ] Tested on Pixel devices
- [ ] No crashes or ANRs above threshold
- [ ] Check Play Vitals memory and the intended bundle's DEX metrics against §17.4; record upcoming gaps, not just R8 flags
- [ ] Where applicable, verify zero-tap sign-in restoration or check Console exemption evidence (§17.4.3)

## Submit
- [ ] Release notes written (what's new)
- [ ] Staged rollout configured (start at 10-20%)
- [ ] Monitoring dashboards ready
- [ ] Review response team alerted
```

---

## 20. Common Rejection Reasons & Fixes

**How to use this table**: It is a quick reference for the most common compliance paths — NOT a finding template. When drafting an actual finding, use the Output Format above and per Rule 6 separate the `Fix` content below into:

- `Required by policy:` — only the outcome-level requirement grounded in the cited text (e.g., the Personal Loans ban on `READ_CONTACTS`).
- `Suggested implementation:` — any specific mechanism listed below (e.g., "switch to Photo Picker", "use Geofence API", "delete the manifest entry") — prefixed "non-policy, auditor's suggestion only".

The `Fix` column may bundle both for brevity; the Output Format must keep them apart.

| Rejection | Root Cause | Fix | Priority |
|-----------|-----------|-----|----------|
| Deceptive behavior | Metadata doesn't match functionality | Align descriptions with actual features | BLOCKER |
| Data Safety mismatch | SDK collects data not declared | Audit all SDKs, update Data Safety form | BLOCKER |
| Privacy policy missing/broken | No policy URL or returns 404 | Host policy and link in Console + app | BLOCKER |
| Financial declaration missing | Required by the distribution track and confirmed incomplete in Play Console | Submit the Financial Features Declaration, including a no-features response when appropriate | BLOCKER |
| Incorrect developer account type | Play Console confirms a covered loan app is owned by a Personal account | Publish from an eligible verified Organization account | BLOCKER |
| Loan-banned permission | `READ_CONTACTS`, `ACCESS_FINE_LOCATION` or another listed permission confirmed in the submitted manifest of a covered loan app | Remove the prohibited permission; no general declaration can waive it | BLOCKER |
| SMS/Call Log eligibility | Permission found, but use case or Play Console approval is not verified | Trace actual use and obtain the applicable eligibility and declaration evidence | NEEDS_CONFIRMATION |
| Over-permissioning | Unnecessary permissions | Remove unused permissions from manifest | BLOCKER |
| Account deletion unmet | Confirmed missing required in-app or web request path, or verified failure to delete covered data | Enable requests and delete associated data subject to disclosed legitimate retention | BLOCKER |
| Minimum functionality | App is essentially a WebView wrapper | Add native functionality beyond WebView | BLOCKER |
| Spyware - no consent | Data collected before user consent shown | Move SDK init after consent dialog | BLOCKER |
| Spyware - SMS exfiltration | Non-financial or personal SMS history exfiltrated or shared | Stop transmitting non-financial/personal SMS (HOW is the developer's choice — see spyware-policy.md §11.4 two-gate model) | BLOCKER |
| Spyware - covert transmission | SDKs transmit data before consent dialog | Delay SDK initialization until after consent | BLOCKER |
| Consent decline ineffective | Decline/Cancel does same as Accept | Make decline genuinely prevent data collection | BLOCKER |
| Disclosure gap | Collected data not in consent dialog | Update consent dialog to list all data types | BLOCKER |
| Loan harassment | Contact data used for debt collection | Stop using contact data for collection/harassment (policy outcome); removing READ_CONTACTS is one common implementation | BLOCKER |
| Short-term personal loan | Actual offer requires full repayment in 60 days or less from issuance without a verified exception | Remove the ineligible offer | BLOCKER |
| Hidden loan fees | Required fees omitted from the actual user-facing disclosures | Disclose all required fees | BLOCKER |
| Hidden functionality | DexClassLoader or remote code execution | Remove dynamic code loading | BLOCKER |
| General contacts/location minimum scope | Target API 37+ broad contacts or one-time/infrequent precise location; check the precise-location declaration separately for effective `ACCESS_FINE_LOCATION` | Verify picker or location button suitability, actual use and declaration where required; apply the loan ban separately | Apply the January 27, 2027 date and declaration/evidence gates |
| Geofencing via foreground service | Service actually implements the geofence; January 27, 2027 rule applies | Remove the geofencing FGS use; assess permissions separately | Assess confirmed service behavior |
| Missing FGS type | Foreground service without type | Add foregroundServiceType in manifest | WARNING |
| Photo permission without declaration | READ_MEDIA_IMAGES without form | Submit declaration or switch to Photo Picker | WARNING |
| Trademark / copyright infringement | Unauthorized bank, lender, or regulator logo in icon, screenshots, or store listing | Replace with owned or licensed assets; remove brand references | BLOCKER |
| Counterfeit / impersonation | App mimics an established bank or lender | Rebrand so the app does not cause source confusion | BLOCKER |
| Harassing language in strings | Threatening / shaming copy in collection notifications | Rewrite to neutral, factual language | BLOCKER |

---

## 21. Key Policy Deadlines (2025-2027)

| Date | Requirement | Impact |
|------|------------|--------|
| May 28, 2025 | Photo/Video permissions full compliance | App removal if non-compliant |
| May 28, 2025 | Line of credit apps must comply with Personal Loan policy | BLOCKER |
| January 1, 2026 | Age Signals API data use restriction (announced Nov 19, 2025) | Policy enforcement |
| January 28, 2026 | Accessibility API: autonomous action prohibition enforced | Policy enforcement |
| March 4, 2026 | Updated Developer Program Policies effective | Full enforcement |
| August 31, 2026 | Mobile submissions target API 36+; existing mobile app discoverability requires API 35+; applicable Play Billing submissions use version 8+ | Submission or availability restrictions, depending on the rule |
| November 1, 2026 | General 2026 target API and Play Billing extensions ended | No longer rely on the extensions |
| January 27, 2027 | Contacts and Location minimum scope, geofencing FGS removal, `READ_CALL_LOG` phone account verification removal, ongoing eligibility-based subscription disclosures | Policy enforcement |
| February 1, 2027 | Trader status declaration for all active developer accounts | Possible update blocks or global app removal |
| February 1, 2027 | 16 KB memory page compatibility for applicable app updates | Incompatible updates cannot be released |
| February 2027 | Memory and DEX quality requirements for in-scope apps and games | May affect visibility and publishing capabilities |
| April 14, 2027 | AppFunctions API policy | Policy enforcement |
| April 2027 | Zero-tap sign-in restoration for in-scope mobile/tablet apps with sign-in | May affect visibility and publishing capabilities; verify any exemption |
| August 25, 2027 | Local network (target API 37+) and manage contacts (target API 38+) | Policy enforcement |

---

## References

- [Policy Announcement: October 29, 2026](https://support.google.com/googleplay/android-developer/answer/18100766)
- [Trader Status Declaration](https://support.google.com/googleplay/android-developer/answer/17594752)
- [Play Console Technical Quality Requirements](https://support.google.com/googleplay/android-developer/answer/17492799)
- [Upcoming Sensitive Permissions and APIs](https://support.google.com/googleplay/android-developer/answer/16909972)
- [Policy Announcement: July 15, 2026](https://support.google.com/googleplay/android-developer/answer/17134731?hl=en)
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
