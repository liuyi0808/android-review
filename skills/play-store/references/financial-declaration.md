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

Complete the Financial Features Declaration for apps published to closed testing, open testing, or production, even if the app has no financial features (declare none). This also covers pregranted and preloaded apps updated through Google Play. Apps active exclusively on internal testing are exempt ([declaration guide](https://support.google.com/googleplay/android-developer/answer/13849271)).

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

For financial features, provide the supporting evidence that applies to the declared activity and markets, including:
- Licensing documentation for applicable countries
- Lender relationships and business model

## 4.3 Personal Loan App Requirements

**Personal Loan definition** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): "We define personal loans as lending money from one individual, organization, or entity to an individual consumer on a nonrecurring basis, not for the purpose of financing purchase of a fixed asset or education."

- **Included**: Personal loans, payday loans, peer-to-peer loans, title loans
- **Not included**: Mortgages, car loans, revolving lines of credit (such as credit cards, personal lines of credit)

For personal loan apps (including direct lenders and facilitators), apply the disclosure and short-term loan rules below. See §4.5 for lines of credit and §4.5.1 for the separate EWA disclosure requirements. Apply the shared sensitive-permission bans to all covered categories, including accessory loan/credit apps (loan calculators, loan guides, etc.).

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
- [ ] No personal loan requires full repayment in **60 days or less** from issuance. Check the actual offer and repayment schedule, not just the advertised duration. For any claimed exception, verify applicability and evidence; Google describes rare Pakistan exceptions where local law explicitly permits them ([source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans)).
- [ ] No access to prohibited sensitive data. Check the effective submitted manifest for the exact [Financial Services prohibited permissions](https://support.google.com/googleplay/android-developer/answer/9876821): `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `QUERY_ALL_PACKAGES`. Do not use the general declaration path to waive any of these bans.
- [ ] SMS/Call Log access and downstream use match the permitted and approved purpose. Approval for SMS-based transaction verification or money management does not cover credit scoring or collection (see permissions.md §3.1).
- [ ] No predatory lending practices (excessive fees, harassment)
- [ ] App category MUST be set to "Finance"

**Conditional check: subscriptions with ongoing eligibility discounts** ([Subscriptions policy](https://support.google.com/googleplay/android-developer/answer/18204939), effective January 27, 2027). Apply only to a subscription whose discount depends on continuing eligibility, not to every fee or ordinary loan repayment. Verify that eligibility criteria are clear and valid and that users can see material terms before purchase without taking extra action. Compare the purchase screen and actual offer configuration with a test eligibility transition: verify the criteria, how eligibility is determined and checked, the non-discounted price or alternative plan, and any benefit changes when eligibility ends. If a subscription fee is part of obtaining the loan, separately check the applicable loan-cost disclosure; satisfying subscriptions disclosure does not replace loan disclosures.

### 4.3.1 High APR Personal Loans (US, outside the default audit scope)

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): "In the United States, we do not allow apps for personal loans where the Annual Percentage Rate (APR) is 36% or higher. Apps for personal loans in the United States must display their maximum APR, calculated consistently with the [Truth in Lending Act (TILA)](https://www.ecfr.gov/cgi-bin/text-idx?c=ecfr&tpl=/ecfrbrowse/Title12/12cfr1026_main_02.tpl)."

This applies to apps which offer loans directly, lead generators, and those who connect consumers with third-party lenders.

- [ ] US-targeted loan apps: APR < 36%
- [ ] US-targeted loan apps: maximum APR displayed, calculated per TILA

## 4.4 Country-Specific Requirements

Use the actual Play Console distribution countries in Africa and Latin America. For each, verify the lender or facilitator role, applicable local licensing and disclosures, and links between the developer, the app and any partner licences. Verify current local requirements with the responsible regulator before a country-level verdict. The [Google Play country-specific list](https://support.google.com/googleplay/android-developer/answer/9876821) currently names Kenya and Nigeria in this scope. Apply global Play rules and applicable local requirements to other target markets, including Latin America. Record `NEEDS_CONFIRMATION` if the countries or the required documentation cannot be established.

| Country | Requirement | Deadline |
|---------|------------|----------|
| Nigeria | Verify the FCCPC approval letter for a Digital Money Lender (DML). For an aggregator, verify the documentation or certification and contact details for every partnered DML. | Active |
| Kenya | Verify the Central Bank of Kenya (CBK) licence and Digital Credit Provider (DCP) directory listing. A facilitator must accurately declare its role and supply its lending partners' DCP licence copies. | Active |

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
| **Fee Structure** | No interest; a low, transparent flat or percentage-based transaction fee reflecting actual cost. Google cites $1–$5 per transaction or 1–5% of the advance as indicative ranges, not automatic pass/fail cutoffs. |
| **No Debt Creation** | Google describes non-reporting to credit bureaus as typical. Review credit reporting and effects on credit or long-term debt when verifying whether the service qualifies as EWA; do not treat the description as a standalone categorical ban. |

**Scope**: EWA direct providers and facilitators must use the `Finance` category and meet the EWA metadata requirements below. Apply the shared sensitive-permission prohibitions, but do not apply the ordinary personal loan APR-disclosure or 60-day repayment rule solely because the app offers EWA. Audit any separately offered personal loans under §4.3.

**Prohibited permissions** (same as Personal Loans — [source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans)):
- `READ_CONTACTS`, `READ_PHONE_NUMBERS`, `ACCESS_FINE_LOCATION`
- `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`
- `QUERY_ALL_PACKAGES`

**Disclosure requirements** (must appear in app description — [source](https://support.google.com/googleplay/android-developer/answer/9876821)):
- [ ] Repayment terms and conditions
- [ ] All fees, including subscription fees, transaction fees, and all other fees related to providing the loan
- [ ] Representative example of total cost, including all fees
- [ ] Comprehensive privacy policy link

**Additional requirements**: Google states "Additional information or documents may be requested to confirm your account is in compliance with all local laws and regulations." EWA apps are subject to country-specific requirements to the extent applicable ([source](https://support.google.com/googleplay/android-developer/answer/9876821)).

**EWA checklist**:
- [ ] Advance amount limited to verified earned wages only
- [ ] No interest; review actual fees for transparency and reasonableness, including any charges if autopay fails
- [ ] Review any credit reporting, credit score impact or long-term debt when verifying product classification
- [ ] App description discloses the repayment terms (payroll deduction or linked-account autopay, as applicable), all fees and a representative total-cost example
- [ ] Privacy policy covers wage data and payroll integration
- [ ] Employer partnership or payroll integration documentation available for Google review
- [ ] No prohibited permissions (contacts, photos, phone numbers, fine location)

## 4.6 Checklist

- [ ] Financial Features Declaration completed for applicable tracks (including a no-features response when appropriate)
- [ ] App category set to "Finance" (if loan/credit app)
- [ ] All licensing documents uploaded for target countries
- [ ] Loan terms displayed in app description
- [ ] No personal loan requires full repayment in 60 days or less from issuance, unless a documented exception applies
- [ ] No access to restricted data (photos, contacts) for lending decisions — SMS governed by separate policy (Section 3.1)
- [ ] EWA apps: verify classification and listing disclosure under §4.5.1 (repayment terms, all fees and a representative total-cost example)
- [ ] EWA apps: employer partnership / payroll integration evidence available
