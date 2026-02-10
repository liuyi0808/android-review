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

## 4.6 Checklist

- [ ] Financial Features Declaration completed in Play Console
- [ ] App category set to "Finance" (if loan/credit app)
- [ ] All licensing documents uploaded for target countries
- [ ] Loan terms displayed in app description
- [ ] No short-term loans (< 60 days)
- [ ] No access to restricted data (photos, contacts) for lending decisions — SMS governed by separate policy (Section 3.1)
