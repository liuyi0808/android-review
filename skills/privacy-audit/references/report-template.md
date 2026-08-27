# Audit Report Template

This template defines the standard format of the privacy compliance audit report. The Markdown output must follow it exactly.

## Report Structure

```
[App Name] Privacy Compliance Three-Way Audit Report

Audit date: YYYY-MM-DD
Privacy policy version: YYYY-MM-DD
App version: X.X.X (Build)

---
1. Executive summary (verdict + issue counts)
2. Comparison tables by category
   2.1 Permission declaration comparison
   2.2 Banned permission check (loan app)
   2.3 User identity data collection comparison
   2.4 Device information collection comparison
   2.5 Installed app list comparison (if applicable)
   2.6 Sensitive data not collected (correctly excluded)
   2.7 Third-party SDK data sharing comparison
   2.8 Data transmission comparison
3. Policy quality check
4. Focused checks (only when the app uses the relevant permission)
   4.1 READ_SMS focused check
   4.2 Installed app list focused check (queries tag)
   4.3 Camera / photos focused check
   4.4 Location focused check
5. Remediation recommendations (if any issues)
```

---

## 1. Executive Summary Template

**Audit verdict**: ✅ Compliant / ⚠️ Remediation required / ❌ Serious violation

| Assessment dimension | Verdict |
|----------------------|---------|
| Google Play loan app policy | ✅/❌ |
| Permission declaration compliance | ✅/❌ |
| Three-way consistency | ✅/⚠️/❌ |
| Data minimization principle | ✅/❌ |
| Informed user consent | ✅/❌ |

**Issue counts**: ❌ BLOCKER: X | ⚠️ WARNING: X

---

## 2. Comparison Table Templates

### Status definitions (apply to every comparison table)

- ✅ Consistent — all three sides map explicitly to each other
- ⚠️ Not explicitly disclosed in dialog — collected in code, possibly covered generically by the policy, but not stated explicitly to the user in the dialog
- ⚠️ Declared in policy/dialog but not collected — recommend removing it from the policy/dialog to avoid over-promising
- ❌ Collected in code but not disclosed — BLOCKER; it must be disclosed explicitly in both the policy and the dialog

### 2.1 Permission declaration comparison

| Permission | Policy disclosure | Dialog disclosure | Code declaration | Status |
|------------|-------------------|-------------------|------------------|--------|
| [permission name] | ✅/⚠️/❌ "[verbatim text]" | ✅/⚠️/❌ "[verbatim text]" | ✅/❌ [AndroidManifest location] | ✅/⚠️/❌ |

### 2.2 Banned permission check (loan app)

| Banned permission | AndroidManifest.xml status | Status |
|-------------------|----------------------------|--------|
| [permission name] | ✅ tools:node="remove" / ❌ declared / ❌ not handled | ✅/❌ |

### 2.3 User identity data collection comparison

| Data item | Policy disclosure | Dialog disclosure | Code collection | Status |
|-----------|-------------------|-------------------|-----------------|--------|
| [data item name] | ✅/⚠️/❌ "[verbatim text]" | ✅/⚠️/❌ "[verbatim text]" | ✅/❌ `file:line` | ✅/⚠️/❌ |

### 2.4 Device information collection comparison

| Data item | Policy disclosure | Dialog disclosure | Code implementation | Status |
|-----------|-------------------|-------------------|---------------------|--------|
| [data item name] | ✅ "[verbatim text]" / ⚠️ generic only / ❌ not mentioned | ✅ "[verbatim text]" / ❌ not explicit | ✅ `file:line` / ❌ not found | ✅/⚠️/❌ |

### 2.5 Installed app list comparison (if applicable)

| Data item | Policy disclosure | Dialog disclosure | Code implementation | Status |
|-----------|-------------------|-------------------|---------------------|--------|
| [data item name] | ✅/⚠️/❌ "[verbatim text]" | ✅/⚠️/❌ "[verbatim text]" | ✅/❌ `file:line` | ✅/⚠️/❌ |

### 2.6 Sensitive data not collected (correctly excluded)

Used to verify that data which is banned, or declared as not collected, really is not collected.

| Data item | Policy declaration | Code verification | Status |
|-----------|--------------------|-------------------|--------|
| [data item name] | [declared content] | [verification result] | ✅ not collected / ❌ violation |

### 2.7 Third-party SDK data sharing comparison

| SDK | Policy disclosure | Dialog disclosure | Code implementation | Status |
|-----|-------------------|-------------------|---------------------|--------|
| [SDK name] | ✅/❌ | ✅/❌ | ✅ [version] / ❌ not integrated | ✅/⚠️/❌ |

### 2.8 Data transmission comparison

| Destination | Policy disclosure | Dialog disclosure | Code implementation | Status |
|-------------|-------------------|-------------------|---------------------|--------|
| [destination] | ✅/❌ "[verbatim text]" | ✅/❌ "[verbatim text]" | ✅/❌ [code location] | ✅/⚠️/❌ |

---

## 3. Policy Quality Check Template

| Check item | Status | Notes |
|------------|--------|-------|
| Last updated date | ✅/❌ | [result] |
| Data controller information | ✅/❌ | [result] |
| Contact details | ✅/❌ | [result] |
| User rights statement | ✅/❌ | [result] |
| Data deletion process | ✅/❌ | [result] |
| Data retention period | ✅/❌ | [result] |
| Data security measures | ✅/❌ | [result] |

---

## 4. Focused Check Templates

### 4.1 READ_SMS focused check

**Include this section only when the app declares the READ_SMS permission.**

| Check item | Result |
|------------|--------|
| Permission status | [declared / removed] |
| Code implementation | [location and status] |
| Policy disclosure | [disclosed content] |

### 4.2 Installed app list focused check (queries tag)

| Check item | Result |
|------------|--------|
| Number of queries tags | [count] |
| App categories | [category notes] |
| Policy disclosure | [disclosed content] |

### 4.3 Camera / photos focused check

**Include this section only when the app declares the CAMERA permission.**

| Check item | Result |
|------------|--------|
| Permission declaration | [status] |
| Purpose of use | [purpose] |
| Policy disclosure | [disclosed content] |
| Dialog notice | [notice content] |

### 4.4 Location focused check

**Include this section only when the app declares a location permission.**

| Check item | Result |
|------------|--------|
| ACCESS_FINE_LOCATION | [status] |
| ACCESS_COARSE_LOCATION | [status] |
| Policy declaration | [declared content] |
| Code implementation | [implementation details] |

---

## 5. Remediation Recommendation Template

**Rules for remediation recommendations:**
1. **Itemize**: every data item marked ⚠️ or ❌ in a comparison table gets its own entry
2. **No merging**: do not combine several issues into one, e.g. "add time zone, screen info, etc."
3. **Priority definitions**:
   - **High priority**: ❌ collected in code but disclosed in neither the policy nor the dialog (BLOCKER)
   - **Medium priority**: ⚠️ collected in code but not explicitly disclosed in the dialog
   - **Low priority**: ⚠️ declared in the policy/dialog but not collected in code
4. **Concrete and actionable**: every recommendation must state exactly what to change and where

### High priority (BLOCKER, must fix)

#### 5.1 [data item name]
- **Issue**: [description]
- **Location**: [file / section]
- **Recommendation**: [specific change]

### Medium priority (fix recommended)

#### 5.2 [data item name]
- **Issue**: [description]
- **Location**: [file / section]
- **Recommendation**: [specific change]

### Low priority (optional improvement)

#### 5.3 [data item name]
- **Issue**: [description]
- **Location**: [file / section]
- **Recommendation**: [specific change]

---

## Status Icon Legend

| Icon | Meaning |
|------|---------|
| ✅ | Compliant / consistent / implemented |
| ❌ | Violation / inconsistent / not implemented |
| ⚠️ | Warning / needs attention / to be confirmed |
| N/A | Not applicable |
