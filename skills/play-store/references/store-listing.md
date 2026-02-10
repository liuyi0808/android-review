# Store Listing & Content Rating

## Table of Contents
- [8. Store Listing](#8-store-listing)
  - [8.1 Required Assets](#81-required-assets)
  - [8.2 Listing Quality](#82-listing-quality)
  - [8.3 Financial App Listing Requirements](#83-financial-app-listing-requirements)
  - [8.4 Metadata Anti-Patterns](#84-metadata-anti-patterns-rejection-triggers)
- [9. Content Rating](#9-content-rating-mandatory)
  - [9.1 Process](#91-process)
  - [9.2 Rules](#92-rules)
  - [9.3 Age-Restricted Content](#93-age-restricted-content-2026-update)

---

## 8. Store Listing

### 8.1 Required Assets

| Asset | Specification |
|-------|--------------|
| App icon | 512x512 PNG, 32-bit, no alpha |
| Feature graphic | 1024x500 PNG or JPEG |
| Screenshots | Min 2, max 8 per device type. Min 320px, max 3840px |
| Phone screenshots | Required. 16:9 or 9:16 recommended |
| Tablet screenshots | Required if app supports tablets |
| Short description | Max 80 characters |
| Full description | Max 4000 characters |

### 8.2 Listing Quality

- [ ] Title: accurate, no keyword stuffing (max 30 chars)
- [ ] Short description: clear value proposition
- [ ] Full description: features and functionality, not marketing fluff
- [ ] Screenshots: actual app UI (not mockups with misleading content)
- [ ] No misleading claims about functionality
- [ ] No references to other platforms ("also on iOS")
- [ ] No excessive capitalization or emoji spam
- [ ] Contact email is valid and monitored

### 8.3 Financial App Listing Requirements

For personal loan apps, the description MUST include:
- [ ] Minimum and maximum repayment period
- [ ] Maximum APR (Annual Percentage Rate)
- [ ] Representative cost example (principal + all fees)
- [ ] Loan service provider name
- [ ] Licensing information for applicable countries

### 8.4 Metadata Anti-Patterns (Rejection Triggers)

- NEVER use "best", "number 1", "#1" without third-party verification
- NEVER reference competitor app names
- NEVER include call-to-action in icon ("FREE", "SALE")
- NEVER show content in screenshots that differs from actual app
- NEVER use misleading app category
- NEVER include promotional pricing that isn't currently active

---

## 9. Content Rating (Mandatory)

### 9.1 Process

1. Complete IARC (International Age Rating Coalition) questionnaire in Play Console
2. Answer questions about: violence, sexual content, language, controlled substances, user interaction, data sharing, location sharing, in-app purchases
3. Receive automatic ratings for multiple regions (ESRB, PEGI, etc.)

### 9.2 Rules

- [ ] Content rating questionnaire completed
- [ ] Rating matches actual app content
- [ ] Re-submit questionnaire if app content changes significantly
- [ ] Apps without rating will be removed from Google Play

### 9.3 Age-Restricted Content (2026 Update)

Starting January 1, 2026:
- Apps with matchmaking, dating, real money gambling, or games/contests must use Play Console features to block minors
- Data from Age Signals API may only be used for age-appropriate experiences
- U.S. state age verification laws (Utah May 2026, Louisiana July 2026) may require additional compliance
