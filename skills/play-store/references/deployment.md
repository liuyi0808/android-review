# Developer Verification, Testing & Post-Launch

## Table of Contents
- [15. Developer Verification (2026)](#15-developer-verification-2026)
- [16. Testing Tracks](#16-testing-tracks)
- [17. Post-Launch Monitoring](#17-post-launch-monitoring)

---

## 15. Developer Verification (2026)

### 15.1 New Requirement

Starting September 2026, Google will require **all Android apps** installed on certified devices to be registered by **verified developers**.

### 15.2 Rollout Schedule

| Date | Region |
|------|--------|
| September 2026 | Brazil, Indonesia, Singapore, Thailand |
| 2027+ | Other regions (gradual rollout) |
| September 2027 | Managed devices (DO) and Work Profiles (BYOD/COPE) |

### 15.3 Impact

- Apps from unverified developers will not install on certified devices
- Existing apps may need developer re-verification
- Enterprise/MDM apps have extended timeline until September 2027

### 15.4 Action Items

- [ ] Verify developer identity in Play Console
- [ ] Ensure organization details (name, address, DUNS) are up to date
- [ ] Prepare for additional verification for Latin American regions (Brazil first batch)

---

## 16. Testing Tracks

### 16.1 Recommended Release Flow

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

### 16.3 AI Review Preparation

Google's review system is increasingly AI-driven. To reduce false rejections:
- [ ] App description precisely matches actual functionality
- [ ] No unused permissions in manifest
- [ ] Data Safety form exactly matches code behavior
- [ ] All SDK data collection declared (Google ML cross-checks APK)
- [ ] No obfuscated or hidden functionality
- [ ] Test account credentials provided if login required

---

## 17. Post-Launch Monitoring

### 17.1 Play Vitals Thresholds

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

**Scale of enforcement**: From early 2024 to April 2025, approximately 1.8 million apps were removed from the Play Store.

### 17.3 Checklist

- [ ] Crash reporting enabled (Firebase Crashlytics or equivalent)
- [ ] ANR monitoring configured
- [ ] Play vitals dashboard reviewed regularly
- [ ] Review response workflow established (respond to 1-star reviews promptly)
- [ ] ProGuard mapping uploaded for each release (crash deobfuscation)
