# Financial Features Declaration (Mandatory for ALL Apps)

## 4.1 Requirement

**ALL apps** on Google Play must complete the Financial Features Declaration in Play Console, even apps without financial features. As of October 30, 2025, **updates cannot be published** until this declaration is completed.

**Path**: Play Console > App content > Financial features declaration

## 4.2 What to Declare

- Whether app contains or promotes financial products/services
- Types of financial features (personal loans, banking, insurance, cryptocurrency, etc.)
- Licensing documentation for applicable countries
- Lender relationships and business model

## 4.3 Personal Loan App Requirements

If your app includes personal loan features (direct lending, loan facilitation, line of credit, EWA):

**Metadata disclosure (in app description)**:
- [ ] Minimum and maximum repayment period
- [ ] Maximum Annual Percentage Rate (APR)
- [ ] Representative example of total loan cost (principal + all fees)
- [ ] Comprehensive privacy policy link

**Documentation upload**:
- [ ] Proof of valid license from relevant authority in each target country
- [ ] Lender information and business relationship
- [ ] Google must be able to verify connection between developer account and licenses

**Prohibitions**:
- [ ] No short-term loans (< 60 days repayment) — only Pakistan has limited exception
- [ ] No access to photos, contacts for risk assessment (explicitly prohibited permissions: `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`)
- [ ] SMS data must NOT be used for credit scoring or lending decisions (see Section 3.1 for full SMS policy details)
- [ ] No predatory lending practices (excessive fees, harassment)
- [ ] App category MUST be set to "Finance"

## 4.4 Country-Specific Requirements

| Country | Requirement | Deadline |
|---------|------------|---------|
| India | Must be on RBI "Digital Lending Apps" list | Oct 30, 2025 |
| Thailand | Display loan service provider, max interest rates, all fees | Mar 4, 2026 |
| Philippines | SEC Registration + Certificate of Authority | Active |
| Nigeria | FCCPC approval letter | Active |
| Pakistan | Only country allowing < 60 day loans (with restrictions) | Active |
| Colombia | Must comply with local financial regulations + global policy | Active |

## 4.5 Line of Credit Apps (April 2025 Update)

As of May 28, 2025, apps providing lines of credit are subject to the same requirements as personal loan apps:
- Disclosure of repayment terms, APR, representative cost
- Prohibition on accessing photos, contacts, location for risk assessment (see Section 3.1 for SMS-specific rules)
- Comprehensive privacy policy

### 4.5.1 Earned Wage Access (EWA) Apps

**Definition (Google)**: EWA apps provide a financial service that allows users to access **wages they have already earned** but have not yet been paid through their regular payroll cycle. EWA is **not** lending against future income — it is early access to money the user has already worked for.

**Three defining characteristics of EWA**:

| Characteristic | Requirement |
|---------------|-------------|
| **Income-Based Access** | Amount strictly limited to wages earned in the current pay cycle. Must not exceed verified earned wages. |
| **Fee Structure** | Low, transparent fees: fixed ($1–$5 per advance) or percentage-based (1–5% of advance). Fees must reflect actual service cost, not disguised interest. |
| **No Debt Creation** | Advances are NOT reported to credit bureaus. No impact on user's credit score. No debt obligation beyond payback from next paycheck. |

**Key distinction from Personal Loans**: EWA is accessing **already-earned** wages, not borrowing against future income. However, Google classifies EWA under the broader Personal Loan policy umbrella for compliance purposes.

**Prohibited permissions** (same as Personal Loans):
- `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`
- `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`

**Disclosure requirements** (same as Personal Loans — must appear in app description):
- [ ] Maximum fee amount or percentage per advance
- [ ] Equivalent APR (if applicable under local regulation)
- [ ] Repayment terms (e.g., auto-deducted from next paycheck)
- [ ] Representative cost example (e.g., "$200 advance → $5 fee → $205 repaid on payday")
- [ ] Comprehensive privacy policy link

**Additional Google requirements for EWA**:
- Google may request **additional documentation** proving EWA status (employer partnerships, payroll integration evidence)
- Google may require **regulatory licenses** specific to EWA in target countries
- If the app's fee structure or repayment model resembles a loan (e.g., multi-cycle repayment, high fees), Google will reclassify it as a Personal Loan app

**EWA checklist**:
- [ ] Advance amount limited to verified earned wages only
- [ ] Fee structure transparent: flat fee ($1–$5) or percentage (1–5%)
- [ ] No credit bureau reporting
- [ ] No impact on user credit score
- [ ] Repayment mechanism clearly disclosed (auto-deduction from payroll)
- [ ] Representative cost example in app description
- [ ] Privacy policy covers wage data and payroll integration
- [ ] Employer partnership or payroll integration documentation available for Google review
- [ ] No prohibited permissions (contacts, photos, phone numbers, fine location)

## 4.6 Checklist

- [ ] Financial Features Declaration completed in Play Console
- [ ] App category set to "Finance" (if loan/credit app)
- [ ] All licensing documents uploaded for target countries
- [ ] Loan terms displayed in app description
- [ ] No short-term loans (< 60 days)
- [ ] No access to restricted data (photos, contacts) for lending decisions — SMS governed by separate policy (Section 3.1)
- [ ] EWA apps: advance limited to earned wages, fees transparent ($1–$5 or 1–5%), no credit bureau reporting
- [ ] EWA apps: representative cost example in app description
- [ ] EWA apps: employer partnership / payroll integration evidence available
