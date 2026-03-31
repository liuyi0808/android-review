# Financial Features Declaration

## Table of Contents
- [4.1 Requirement](#41-requirement)
- [4.2 What to Declare](#42-what-to-declare)
- [4.3 Personal Loan App Requirements](#43-personal-loan-app-requirements)
- [4.4 Country-Specific Requirements](#44-country-specific-requirements)
- [4.5 Line of Credit Apps (April 2025 Update)](#45-line-of-credit-apps-april-2025-update)
  - [4.5.1 Earned Wage Access (EWA) Apps](#451-earned-wage-access-ewa-apps)
- [4.6 Checklist](#46-checklist)

---

## 4.1 Requirement

Any app that contains any financial features must complete the Financial Features Declaration form in Play Console ([source](https://support.google.com/googleplay/android-developer/answer/9876821)).

**Path**: Play Console > App content > Financial features declaration

## 4.2 What to Declare

You must declare whether your app contains or promotes financial products/services, and select all applicable categories ([source](https://support.google.com/googleplay/android-developer/answer/13849271)):

| Category Group | Specific Types |
|---------------|----------------|
| **Banking and loans** | Personal loan direct lender, Loan facilitator, Payday loans, Banking, Line of credit, Earned wage advances, Microfinance banking |
| **Payments and transfers** | Mobile payments / digital wallets, Money transfer / wire services |
| **Purchase agreements** | Rewards / points, Buy now pay later |
| **Trading and funds** | Crypto wallet, Crypto exchange, NFTs, Stock trading, Crowdfunding / chit funds |
| **Support services** | Credit monitoring, Financial advice, Insurance, Other |

You must also provide:
- Licensing documentation for applicable countries
- Lender relationships and business model

## 4.3 Personal Loan App Requirements

**Personal Loan definition** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): "We define personal loans as lending money from one individual, organization, or entity to an individual consumer on a nonrecurring basis, not for the purpose of financing purchase of a fixed asset or education."

- **Included**: Personal loans, payday loans, peer-to-peer loans, title loans
- **Not included**: Mortgages, car loans, revolving lines of credit (such as credit cards, personal lines of credit)

If your app includes personal loan features (direct lending, loan facilitation, line of credit, EWA), or is an **accessory loan/credit app** (loan calculators, loan guides, etc.):

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
- [ ] No short-term loans (< 60 days repayment) — only Pakistan has rare exceptions when explicitly permitted by local laws ([source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans))
- [ ] No access to sensitive data for risk assessment. Prohibited permissions ([source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans)): `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEOS`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `QUERY_ALL_PACKAGES`
- [ ] SMS data must NOT be used for credit scoring or lending decisions (see Section 3.1 for full SMS policy details, including stricter SMS history access restrictions for financial apps)
- [ ] No predatory lending practices (excessive fees, harassment)
- [ ] App category MUST be set to "Finance"

### 4.3.1 High APR Personal Loans (US)

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): "In the United States, we do not allow apps for personal loans where the Annual Percentage Rate (APR) is 36% or higher. Apps for personal loans in the United States must display their maximum APR, calculated consistently with the [Truth in Lending Act (TILA)](https://www.ecfr.gov/cgi-bin/text-idx?c=ecfr&tpl=/ecfrbrowse/Title12/12cfr1026_main_02.tpl)."

This applies to apps which offer loans directly, lead generators, and those who connect consumers with third-party lenders.

- [ ] US-targeted loan apps: APR < 36%
- [ ] US-targeted loan apps: maximum APR displayed, calculated per TILA

## 4.4 Country-Specific Requirements

| Country | Requirement | Deadline |
|---------|------------|----------|
| India | Must be on RBI "Digital Lending Apps (DLAs) deployed by Regulated Entities" [list](https://support.google.com/googleplay/android-developer/answer/16604194); NBFC names in app description. New apps: Oct 30, 2025. Existing apps: Jan 28, 2026. | Jan 28, 2026 |
| Indonesia | Valid OJK license (OJK Regulation No. 77/POJK.01/2016, as may be amended from time to time) | Active |
| Philippines | Corporate Name, Business Name, PSEC Registration Number, and Certificate of Authority (CA) — all four must be disclosed in app description ([source](https://support.google.com/googleplay/android-developer/answer/9876821)). | Active |
| Nigeria | FCCPC approval letter for Digital Money Lenders (DML). Loan Aggregators must provide documentation and contact details for every partnered DML. | Active |
| Kenya | CBK Digital Credit Provider (DCP) license; must be on CBK Directory. Platform/facilitators not directly lending must provide partner DCP license copies. | Active |
| Pakistan | SECP approval required; each NBFC limited to 1 DLA; short-term loans rare exception only when explicitly permitted by local laws. | Active |
| Thailand | BoT or MoF license (if interest ≥ 15%); apps below 15% must state "This is a non-regulated loan provider under the BoT/FPO". Listing must display: loan service provider name, legal entity name, max interest rates, all fees. New apps: immediate. Existing apps: Mar 4, 2026. | Mar 4, 2026 |

### 4.4.1 Cryptocurrency / Blockchain (If Applicable)

If your financial app handles cryptocurrency payments, exchanges, or wallets, additional policies apply:
- [Blockchain-based Content policy](https://support.google.com/googleplay/android-developer/answer/13607354)
- [Cryptocurrency Exchanges and Software Wallets — country-specific requirements](https://support.google.com/googleplay/android-developer/answer/16329703)

## 4.5 Line of Credit Apps (April 2025 Update)

Effective since May 2025 ([announced April 10, 2025](https://support.google.com/googleplay/android-developer/answer/15899442)), apps providing lines of credit are subject to the same requirements as personal loan apps:
- Disclosure of repayment terms, APR, representative cost
- Prohibition on accessing photos, contacts, location for risk assessment (see Section 3.1 for SMS-specific rules)
- Comprehensive privacy policy

### 4.5.1 Earned Wage Access (EWA) Apps

**Definition (Google)** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): "We define earned wage access loans (EWA) as a financial service that allows individuals to access a portion of their wages that have already been earned but not yet paid by their employer."

**Four defining characteristics of EWA** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)):

| Characteristic | Requirement (policy text) |
|---------------|-------------|
| **Repayment Mechanism** | "Repayment occurs automatically via payroll deduction or through an autopay transaction linked to the user's bank account. If the autopay transaction fails, no additional interest, penalties, or fees are charged." |
| **Income-Based Access** | Amount strictly limited to wages earned in the current pay cycle. Must not exceed verified earned wages. |
| **Fee Structure** | "EWA services charge **no interest** and instead charge a low, flat fee or a percentage based transaction fee for usage." Reasonable fee range: $1–$5 per transaction or 1–5% of the advance. |
| **No Debt Creation** | "EWA services typically do not report transactions to credit bureaus, ensuring they do not impact the user's credit score or contribute to long-term debt accumulation." |

**Note**: Google explicitly classifies EWA as a type of **loan** ("earned wage access loans") and applies the Personal Loan policy framework to EWA apps, including prohibited permissions and disclosure requirements.

**Prohibited permissions** (same as Personal Loans — [source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans)):
- `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`
- `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEOS`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`
- `QUERY_ALL_PACKAGES`

**Disclosure requirements** (must appear in app description — [source](https://support.google.com/googleplay/android-developer/answer/9876821)):
- [ ] Repayment terms and conditions
- [ ] All fees, including subscription fees, transaction fees, and all other fees related to providing the loan
- [ ] Representative example of total cost, including all fees
- [ ] Comprehensive privacy policy link

**Additional requirements**: Google states "Additional information or documents may be requested to confirm your account is in compliance with all local laws and regulations." EWA apps are subject to country-specific requirements to the extent applicable ([source](https://support.google.com/googleplay/android-developer/answer/9876821)).

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
