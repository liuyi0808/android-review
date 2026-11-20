# Loan App Harassment & Predatory Lending (Financial Apps Only)

## Table of Contents
- [14.1 Prohibited Contact/Harassment Practices](#141-prohibited-contactharassment-practices)
- [14.2 Predatory Lending Indicators](#142-predatory-lending-indicators)
- [14.3 Data Usage for Lending Decisions](#143-data-usage-for-lending-decisions)
- [14.4 Loan App Harassment Checklist](#144-loan-app-harassment-checklist)

---

Google Play has specific policies targeting predatory lending and aggressive debt collection practices, particularly in emerging markets.

### 14.1 Prohibited Contact/Harassment Practices

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9876821)): `READ_CONTACTS` is prohibited for the covered loan categories regardless of purpose. For picker and manually entered reference flows, trace the exact fields, destinations and documented purpose, including any use for underwriting, collections, or disclosure of the user's debt to other people. Do not treat the existence of a picker as either compliance or a second permission violation; apply the sensitive-data and harassment rules to what the app actually does. See `permissions.md` §§3.1.4 and 3.9.

**Enforcement-derived practices** (inferred from the blanket contact ban and consistent Google Play enforcement patterns against predatory loan apps, not verbatim policy text):
- Send automated messages to user's contacts about overdue loans
- Call/message user's emergency contacts for debt collection
- Use aggressive notification patterns to pressure repayment
- Threaten users with exposure or public shaming

**Code audit**:
```bash
# Check for contact list access for collection:
grep -rn "ContactsContract\|READ_CONTACTS\|WRITE_CONTACTS" --include="*.kt"

# Check for automated SMS sending:
grep -rn "SmsManager\|sendTextMessage\|sendMultipartTextMessage" --include="*.kt"

# Check for automated calling:
grep -rn "ACTION_CALL\|ACTION_DIAL\|TelecomManager" --include="*.kt" | grep -v "intent.*filter"

# Check for aggressive notification patterns:
grep -rn "NotificationManager\|NotificationCompat\|createNotificationChannel" --include="*.kt"
# Then check notification frequency/scheduling

# Check for debt collection related strings:
grep -rn "cobro\|cobranza\|mora\|deuda\|vencido\|atrasado\|overdue\|default\|delinquent" --include="*.xml" --include="*.kt" -i

# Check for emergency contact usage beyond declared purpose:
grep -rn "emergency.*contact\|contacto.*emergencia\|reference.*contact" --include="*.kt" -i
```

- [ ] No READ_CONTACTS permission (or explicitly removed via tools:node="remove")
- [ ] No automated SMS sending to user's contacts
- [ ] No automated calling to user's contacts
- [ ] Any reference/contact processing has been traced to its real use; no prohibited access or use for harassment
- [ ] Notification frequency is reasonable (not spamming overdue reminders)
- [ ] No threatening or shaming language in any UI or notification

### 14.2 Predatory Lending Indicators

Google flags apps that exhibit predatory lending patterns:

**Code audit**:
```bash
# Check for extremely short loan terms:
grep -rn "repayment.*day\|plazo.*dia\|term.*day\|loan.*period" --include="*.kt" --include="*.xml" -i
# Verify when the actual offer requires full repayment from the date of issuance.

# Check for hidden fees:
grep -rn "fee\|cargo\|comision\|cuota.*manejo\|penalty\|penalidad\|recargo" --include="*.xml" --include="*.kt" -i

# Check for maximum APR disclosure:
grep -rn "APR\|tasa.*anual\|interest.*rate\|tasa.*interes" --include="*.xml" --include="*.kt" -i
```

- [ ] A personal loan requiring full repayment in **60 days or less** from issuance is a **BLOCKER** absent a verified exception (`financial-declaration.md` §4.3). An earlier installment or optional early payoff is not evidence that full repayment is required by day 60.
- [ ] All fees clearly disclosed before loan agreement
- [ ] APR clearly displayed and not misleading
- [ ] No hidden fees or charges added after loan agreement
- [ ] No excessive late payment penalties

### 14.3 Data Usage for Lending Decisions

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9876821#personal-loans)): Personal loan apps, accessory loan/credit apps, and EWA apps are prohibited from accessing sensitive data. The following permissions are **entirely banned** regardless of purpose:

| Data Type | Permission Status | Policy Source |
|-----------|------------------|---------------|
| Contact list | **BANNED** — `READ_CONTACTS` is prohibited; assess any picker/manual flows separately | Financial Services General Requirements |
| Photos/media | **BANNED** — `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` | Financial Services General Requirements |
| Fine location | **BANNED** — `ACCESS_FINE_LOCATION` entirely prohibited | Personal Loans Policy |
| Phone numbers | **BANNED** — `READ_PHONE_NUMBERS` entirely prohibited | Personal Loans Policy |
| Installed apps | **BANNED** — `QUERY_ALL_PACKAGES` entirely prohibited | Personal Loans Policy + QUERY_ALL_PACKAGES Policy |
| SMS content | Governed by SMS/Call Log Policy (requires exception approval); non-financial SMS exfiltration prohibited | Spyware Policy ([source](https://support.google.com/googleplay/android-developer/answer/14745000)) |
| Coarse location | Not in the prohibited list; verify core need, minimum scope and actual handling | Location, User Data and Data Safety policies |
| Device ID | Not in prohibited list; allowed with proper disclosure | Must declare in Data Safety |
| Financial records (credit bureau) | Allowed | Standard practice |

**Code audit**:
```bash
# Check if SMS data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "sms\|message"

# Check if app list flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "app\|package\|install"

# Check if contact data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "contact"
```

- [ ] Trace SMS data to downstream decisions. Verify the actual use falls under the permitted and approved core purpose (§3.1); cleaning or filtering the payload does not extend a transaction/budgeting approval to underwriting or collection. Apply the [Spyware policy data-sharing check](spyware-policy.md#114-category-4-personal-smscall-log-exfiltration-critical-for-loan-apps) separately.
- [ ] `QUERY_ALL_PACKAGES` permission not declared (entirely banned for loan apps per 14.3 table). Targeted `<queries>` block is the allowed alternative; per [permissions.md#3.2](permissions.md#32-query_all_packages-installed-apps-visibility), `<queries>` packages must have documented business justification. Note: the QUERY_ALL_PACKAGES policy explicitly states credit-assessment use cases are "NOT eligible" for that permission's exception — this is a policy signal about the use case, but does not constitute a verbatim ban on `<queries>`-block-derived installed-app data. Auditor flags this as a risk for developer review, not as a direct BLOCKER.
- [ ] Contact data NOT used for credit scoring (`READ_CONTACTS` entirely banned per 14.3 table)
- [ ] Photos/media NOT used for credit scoring (entirely banned per 14.3 table)
- [ ] Fine location NOT used for credit scoring (`ACCESS_FINE_LOCATION` entirely banned per 14.3 table)

### 14.4 Loan App Harassment Checklist

- [ ] No contact list access for debt collection
- [ ] No automated communication to user's contacts
- [ ] Emergency contacts protected from collection use
- [ ] Reasonable notification frequency
- [ ] No threatening or shaming language
- [ ] No personal loan requires full repayment in 60 days or less from issuance, unless a documented exception applies
- [ ] All fees disclosed upfront
- [ ] Prohibited data types not used for lending decisions
