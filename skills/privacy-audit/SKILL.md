---
name: privacy-audit
description: >-
  Three-way privacy compliance audit for Android loan apps, verifying that the
  privacy policy, in-app disclosure dialogs, and code implementation are
  consistent. Use for pre-submission review on Google Play, periodic compliance
  checks, and verification before an app update. Prefer this skill when the user
  mentions "privacy audit", "privacy compliance", "three-way comparison",
  "Google Play policy", "loan app review", or "READ_SMS compliance".
---

# Privacy Audit Skill

Run a "three-way comparison" privacy compliance audit on an Android loan app to confirm that the privacy policy, in-app disclosure dialogs, and code implementation all agree, and that the result satisfies Google Play policy.

## Audit Goals

Loan apps are subject to extra privacy policy requirements on Google Play. This skill performs:

1. **Three-way consistency comparison**: privacy policy ↔ in-app dialogs ↔ code implementation
2. **Google Play policy compliance**: global policy plus region-specific requirements
3. **Sensitive permission checks**: permissions banned for loan apps, sensitive data collection
4. **Third-party SDK audit**: completeness of data-sharing disclosure

## Audit Workflow

**⚠️ Mandatory execution order — violating this order invalidates the audit:**

```
Step 1 (code scan) → Step 2 (choose policy source) → Step 3 (fetch policy) → Step 4 (three-way comparison) → Step 5 (generate report)
```

**Forbidden:**
- ❌ Reading or analyzing the privacy policy before Step 1 is complete
- ❌ Skipping Step 2 and directly using a URL found in the code
- ❌ Asking the user for the policy before the code scan is complete

### Step 1: Scan the Code (must run first)

**This is the most important step; the code must be read before any three-way comparison. Until this step is complete, no policy-related operation is allowed.**

**Core principle**: discover every piece of data the app actually collects. Do not limit yourself to the examples listed below. Each app collects data differently, so analyze the actual code rather than following a fixed list.

#### 1.1 Read the core configuration files
```bash
# Required reads
Read app/src/main/AndroidManifest.xml       # permissions, queries tags
Read app/build.gradle or app/build.gradle.kts  # SDK dependencies, versions
Read app/src/main/res/values/strings.xml    # dialog text
```

#### 1.2 Scan data collection exhaustively (discovery-driven, not checklist-driven)

**Core principle: do not rely on a predefined keyword list — find every data collection point from the actual code.**

**Scanning strategy:**

1. **Start from API requests (the most reliable data exit point)**
   - Locate every network request interface definition
   - Read the request body structure of each upload endpoint
   - Analyze **every field** in the request body one by one, tracing each back to the code that produces it

2. **Start from data models**
   - Search for `data class`, `Request`, `Dto`, `Model`, and similar types
   - Read the model files you find and analyze **all fields**
   - Keep asking: where does this field's value come from? What user/device data does it collect?

3. **Start from permissions**
   - For each permission declared in AndroidManifest, search for the code that uses it
   - Do not assume a permission maps to a fixed API — search and verify

4. **Start from SDKs**
   - Collect every third-party SDK from build.gradle
   - Search for each SDK's initialization and configuration code
   - Check configuration options related to data collection

**Forbidden:**
- ❌ Searching only a predefined keyword list (e.g. only `Build.*`, `TelephonyManager`)
- ❌ Assuming the "common" fields are all of them and ignoring collection outside the list
- ❌ Seeing 20 fields in a request body and analyzing only the few that "look sensitive"

**Correct approach:**
- ✅ Read the actual request body definition and list **every** field
- ✅ Trace each field back to the code that sources the data
- ✅ Find and report data collection points that are not on any list

#### 1.3 Extract disclosure dialog text
**Find permission explanations and data collection disclosures in strings.xml and the localized files:**
- Search for strings containing keywords such as permission, privacy, data, collect
- Record the actual dialog text verbatim

**When the scan is done, consolidate every data collection point you found — this is the basis of the three-way comparison.**

### Step 2: Ask the User to Choose the Privacy Policy Source

**After the Step 1 code scan, you must ask the user to pick the policy source. Using a URL found in the code automatically is forbidden.**

Once the code scan is complete, show the user any policy URLs you discovered and ask them to choose:

```
Code scan complete. I found the following privacy policy URLs in the code:
- [list the URLs found in build.gradle, strings.xml, or source code]

Please choose the privacy policy source:
1. Use the URL from the code: [specific URL]
2. Provide a different URL
3. Provide a local file path

Enter an option number, or provide a URL / file path directly:
```

If no URL was found in the code:
```
Code scan complete. No privacy policy URL was found in the code.

Please provide the privacy policy source:
1. Provide a URL
2. Provide a local file path

Enter a URL or file path:
```

**Do not continue until the user has made an explicit choice.**

### Step 3: Fetch the Privacy Policy Content

Fetch the policy according to the user's Step 2 choice:

**If it is a URL:**
1. Try the `WebFetch` tool first
2. If that fails, use MCP Playwright:
   - `mcp__plugin_playwright_playwright__browser_navigate` to open the URL
   - `mcp__plugin_playwright_playwright__browser_snapshot` to capture the page content
   - `mcp__plugin_playwright_playwright__browser_close` to close the browser
3. If both fail, ask the user to paste the text manually

**If it is a local file:**
1. Read the file with the Read tool
2. Supported formats: .txt, .md, .html, .pdf

### Step 4: Three-Way Comparison Analysis

**The comparison must be based on the Step 1 code scan results and the Step 3 policy content.**

#### ⚠️ Bidirectional comparison principle (core requirement)

The three-way comparison must run in **both directions**:

| Direction | Issue type | Severity |
|-----------|-----------|----------|
| **Code → policy/dialog** | Collected in code but not disclosed in the policy/dialog | **BLOCKER** |
| **Policy/dialog → code** | Declared in the policy/dialog but not collected in code | WARNING |

**Emphasis**: use the data the code actually collects as the baseline, and check one by one whether the policy and the dialog disclose it **explicitly**. A generic phrase (e.g. only "hardware information") does not count as explicit disclosure.

#### Comparison requirements

1. **Full coverage**: every data collection point found in Step 1 must appear in a comparison table
2. **Explicit disclosure**: the policy/dialog must name the specific data item; a generic phrase does not cover it
3. **Cite code locations**: every data item must cite a concrete file name and line number
4. **Quote the source text**: policy and dialog disclosures must be quoted verbatim, not summarized as "disclosed"

#### Status definitions

- ✅ Consistent — both the policy and the dialog **explicitly contain** the field name or an equivalent description
- ⚠️ Not explicitly disclosed in dialog — collected in code, but the dialog text does not mention the field explicitly
- ⚠️ Declared in policy/dialog but not collected — recommend removing it from the policy/dialog to avoid over-promising
- ❌ Collected in code but not disclosed — BLOCKER; it must be disclosed explicitly in both the policy and the dialog

**Bar for marking ✅ Consistent**: the policy/dialog text must explicitly contain the field name or an equivalent description. "Implied by hardware info" or "implied by Device Status" is not explicit disclosure and must be marked ⚠️.

### Step 5: Generate the Audit Report

**The report must follow the structure below exactly. Custom section structures or numbering are forbidden.**

#### 5.1 Report structure (mandatory)

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

#### 5.2 Mandatory rules

1. **Section numbers and titles must match the structure above exactly** — no edits, merges, or splits
2. **No custom sections** (e.g. "Data Flow and Servers", "Google Play Policy Compliance Check")
3. **Each comparison table must use the columns defined in** `references/report-template.md`
4. **Remediation recommendations must be itemized** — every data item marked ⚠️ or ❌ in a comparison table gets its own entry; merging is forbidden
5. **Focused check sections** are included only when the app uses the relevant permission; omit the subsection otherwise
6. **Header must be complete**: audit date, privacy policy version, and app version are all required

#### 5.3 Output file

1. Use the Write tool to create `privacy-audit-report-[YYYY-MM-DD].md`
2. Save it in the project root or a location the user specifies
3. Check for an existing file with the same name first; if one exists, ask the user whether to overwrite

## Google Play Policy Highlights

See `references/google-play-policies.md` for details.

### Permissions banned for loan apps (must use tools:node="remove")
- READ_CONTACTS / WRITE_CONTACTS
- READ_CALL_LOG / WRITE_CALL_LOG
- READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE
- READ_MEDIA_IMAGES / READ_MEDIA_VIDEO
- ACCESS_FINE_LOCATION (COARSE only)
- READ_PHONE_STATE / READ_PHONE_NUMBERS
- QUERY_ALL_PACKAGES
- CAMERA (banned in some regions)

### READ_SMS special requirements
A loan app that needs to read SMS must:
1. Read only finance-related messages (filter by keyword)
2. State this explicitly in the privacy policy
3. Inform the user explicitly in the app
4. Implement the filtering logic in code

### Data minimization principle
- Collect only the data the business genuinely requires
- What the policy discloses = what the dialog tells the user = what the code actually collects
- Data that is not collected must not appear anywhere
