# Developer Verification, Testing & Post-Launch

## Table of Contents
- [15. Developer Verification (2026)](#15-developer-verification-2026)
  - [15.4 Trader Status Declaration](#154-trader-status-declaration)
- [16. Testing Tracks](#16-testing-tracks)
- [17. Post-Launch Monitoring](#17-post-launch-monitoring)
  - [17.4 Technical Quality Requirements](#174-technical-quality-requirements)

---

## 15. Developer Verification (2026)

### 15.1 Organization Registration Requirement

Developers providing the following services must register as an **Organization** account (not individual) in Play Console ([source](https://support.google.com/googleplay/android-developer/answer/14993590)):
- Financial products and services
- Health
- VPN
- Government

For a personal loan app, obtain evidence of the owning Play Console account's Organization type and completed identity verification. A confirmed Personal account or a confirmed account-verification block is a `BLOCKER` for release readiness. If the account type or verification status cannot be established, record `NEEDS_CONFIRMATION`.

### 15.2 Action Items

- [ ] Play Console account registered as Organization (not individual)
- [ ] Organization identity verified (name, address, DUNS number)
- [ ] Developer entity and licence holder linkage verified where applicable (§4.4)
- [ ] Monitor Play Console for additional verification requirements as they are announced

### 15.3 App Registration Requirement (July 2026)

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/17134731)): All Play apps must be registered in Play Console to meet Android developer verification requirements. This ensures Google can verify app ownership and enforce policies consistently across the ecosystem.

> "Non-compliance risks global removal from Google Play."

**Status**: 99% of apps were auto-registered in July 2026. Check your Play Console Home page to verify registration status.

**Additional distribution channels** ([Android developer verification](https://developer.android.com/developer-verification)): For Brazil, Google lists September 30, 2026 as the start of installation protections for participating stores on certified Android devices running Android 8+. If the package is also distributed outside Play, identify the actual channel, markets and devices, and verify the developer and package registration against the official rollout for that channel. Record the Play registration separately.

- [ ] Verify app registration status in Play Console Home page
- [ ] Ensure all published apps appear in registered apps list
- [ ] For additional distribution channels, check whether Android developer verification and package registration apply

### 15.4 Trader Status Declaration

**Scope and deadline** ([Play Console Help](https://support.google.com/googleplay/android-developer/answer/17594752)): All active Google Play developer accounts must declare trader or non-trader status by **February 1, 2027**, regardless of distribution markets. The rollout beginning in November 2026 is not the deadline. Developers not distributing in the EEA or UK can declare as non-traders under Google's guidance; they still have to declare. Developer identity verification, D-U-N-S verification and the Financial Features Declaration are separate checks and do not satisfy this requirement.

**Console evidence to request** (redact unnecessary personal information):

1. Account level: **Manage account > Account details > About you**. Check the owner account's submitted status and any outstanding confirmation request, including its response deadline.
2. For trader accounts: **Monitor and improve > Policy and programs > App content**. Confirm each app's status, verify the trader self-certification and the terms-of-service link for each app. Where applicable, check the requested public contact information. Record status and evidence for the audited app, never infer legal classification from a free listing or Organization account type alone.
3. Missing Console evidence is `NEEDS_CONFIRMATION`. Known incomplete work before February 1 belongs in Upcoming Policy Readiness with an owner and completion date. After the deadline, proven missing required declaration is a `BLOCKER` for release readiness. Independently report any account-specific enforcement notice and response deadline, even before the general deadline.

**Enforcement**: Missing the deadline may block updates or lead to global removal of apps. A false declaration may result in account suspension or termination; failure to respond to a status confirmation request may also lead to removal. Do not state that an app has been removed without Console evidence.

---

## 16. Testing Tracks

### 16.1 Recommended Release Flow

Assess the test tracks used by the Organization account and any app-specific Console requirements. Mark Personal developer account production access as `Not Applicable` for this loan audit.

```
Internal Testing → Closed Testing → Open Testing → Production
```

| Track | Audience | Data Safety Required | Financial Declaration Required | Review |
|-------|----------|---------------------|-------------------------------|--------|
| Internal | Up to 100 testers | No | No | No review |
| Closed | Invited testers | Yes | Yes | Full review |
| Open | Anyone can join | Yes | Yes | Full review |
| Production | All users | Yes | Yes | Full review |

### 16.2 Pre-Launch Report

- [ ] Enable pre-launch report in Play Console
- [ ] Review automated test results (crashes, performance, accessibility)
- [ ] Fix critical issues before promotion to production
- [ ] Test on Pixel devices (Google reviewers use these)
- [ ] Test on multiple API levels (min SDK through target SDK)

### 16.3 Reviewer Access

For restricted functionality, verify the [Play Console App access instructions](https://support.google.com/googleplay/android-developer/answer/15748846) with a dedicated test account. The credentials must remain valid and reusable across locations. Provide English instructions and reusable access when normal sign-in requires a one-time password, multi-factor authentication or a regional code. Include instructions for external sign-in, PINs or static QR/barcode credentials as applicable.

Replay the submitted instructions against the intended build. Verify access to relevant restricted flows such as application, KYC and repayment using test data. Use isolated reviewer credentials and compare the visible functionality with equivalent ordinary-user flows (`deceptive-behavior.md` §10.5). Record the flows reached and any obstacle, without copying credentials into the audit report. If testing or Console evidence is unavailable, record `NEEDS_CONFIRMATION`.

---

## 17. Post-Launch Monitoring

### 17.1 Play Vitals Thresholds *(from [Android Vitals documentation](https://developer.android.com/topic/performance/vitals))*

| Metric | Threshold | Action if Exceeded |
|--------|-----------|-------------------|
| ANR rate | 0.47% | App may be deprioritized in search |
| Crash rate | 1.09% | App may be deprioritized in search |
| Permission denial rate | High = bad UX signal | Review permission strategy |
| Uninstall rate | Spike after update | Investigate regression |

### 17.2 Enforcement Actions

If policy violated:
1. **Warning** → fix within deadline (usually 7-30 days)
2. **App removal** → fix and resubmit
3. **Account suspension** → repeated violations or egregious breach

**Scale of enforcement**: *(reported in Google developer blog/conference, not in official policy text)* From early 2024 to April 2025, approximately 1.8 million apps were removed from the Play Store.

### 17.3 Checklist

- [ ] Crash reporting enabled (Firebase Crashlytics or equivalent)
- [ ] ANR monitoring configured
- [ ] Play vitals dashboard reviewed regularly
- [ ] Review response workflow established (respond to 1-star reviews promptly)
- [ ] ProGuard mapping uploaded for each release (crash deobfuscation)

### 17.4 Technical Quality Requirements

Use the [Play Console technical quality requirements and FAQs](https://support.google.com/googleplay/android-developer/answer/17492799) and the [Android Developers enforcement announcement](https://android-developers.googleblog.com/2026/08/app-quality-memory-optimization-secure-onboarding.html). These are mandatory for the applicable scope when enforcement starts, not optional optimization tips. The official sources specify **February 2027** and **April 2027**, not exact dates. Check the app's Console notices for more specific rollout or enforcement details. Failure to meet a requirement may reduce visibility or restrict publishing capabilities; do not report automatic global removal for a failed quality metric.

#### 17.4.1 Memory: February 2027

- Applies to mobile and tablet. Play evaluates app versions with data on Android 13+, not just Android 17+. Use **Android vitals > Overview > Memory** (or the Google Play Developer Reporting API). Record the 28-day period, app version/cohort where available, app state, device RAM tier, P90 and any Console warning. Missing telemetry or a local profiler run cannot establish a Play Vitals pass.
- For non-game apps (including loans), compare P90 **Anonymous RSS + Swap** against the three state-specific limits below. Use the official Games table for games. Google does not list thresholds for cached RSS + Swap or for the lowest/highest RAM bands in this table; do not invent thresholds for unlisted cells.

| Total device memory (MB) | Foreground P90 | User-perceived services P90 | Background P90 |
|--------------------------|----------------|-----------------------------|----------------|
| 3,200 to <4,800 | 2 GB | 1 GB | 1 GB |
| 4,800 to <6,800 | 2.25 GB | 1.25 GB | 1.25 GB |
| 6,800 to <9,216 | 2.25 GB | 1.5 GB | 1.5 GB |
| 9,216 to <14,336 | 3.25 GB | 1.75 GB | 1.75 GB |
| 14,336 to <18,432 | 4.25 GB | 2 GB | 2 GB |

- Separately check **Bitmap memory** P90: exceeding **200 MB** in user-perceived services or background, or **400 MB** when cached, crosses the published thresholds. No foreground threshold is listed. For loan-app investigation, profile camera/KYC, document previews and image-heavy screens, including memory retained after navigating away. Local profiling diagnoses causes; Play telemetry is the compliance evidence.

#### 17.4.2 DEX code optimization: February 2027

- All form factors. Applies to submitted app bundles with **DEX code >10 MB for apps** or **>50 MB for games**. Use DEX size, not total AAB or APK size. Each of **obfuscation, optimization and shrinking** must separately reach at least **25%**. Do not average them.
- Verify the planned upload/version in **App bundle explorer**. Record the version code, reported DEX size, each of the three percentages and any upload restriction. R8 settings and broad keep rules are investigation leads, not proof of a passing percentage. Google permits tools other than R8. Use an existing uploaded bundle for audit evidence; do not run a Release build as part of the audit.

#### 17.4.3 Zero-tap sign-in restoration: April 2027

- Applies to mobile/tablet apps with optional or mandatory sign-in when a previously signed-in user migrates to a new device and restores their data via device transfer or cloud backup. Restore Credentials is Google's primary path on Android 9+. Existing Block Store sign-in restoration integrated on or before September 30, 2026 is accepted. Games, permanently private apps and enterprise device management apps are out of scope under current guidance.
- Financial apps are **not automatically exempt**. If a specific regulatory or compliance mandate affects sign-in, record the mandate and impacted authentication step; verify a Play Console exemption request was submitted before enforcement and record its decision. A pending request is not an approved exemption. Otherwise verify actual sign-in restoration with test accounts on a supported device/restore flow. Restoration does not replace authorization or step-up checks for regulated or sensitive actions.

**Report verdicts**: Before enforcement, record verified gaps in Upcoming Policy Readiness. For active requirements, report confirmed out-of-threshold Vitals as `WARNING` with the documented visibility/publishing risk; flag a verified current publishing block as `BLOCKER`. For DEX and sign-in, confirmed failure to meet an active applicable release requirement is `BLOCKER` for release readiness; do not represent that as a Console block or takedown unless confirmed. Missing telemetry, submitted-bundle metrics, authentication evidence or exemption status is `NEEDS_CONFIRMATION`, not a pass.
