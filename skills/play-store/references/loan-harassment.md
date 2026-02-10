# Loan App Harassment & Predatory Lending (Financial Apps Only)

## Table of Contents
- [14.1 Prohibited Contact/Harassment Practices](#141-prohibited-contactharassment-practices)
- [14.2 Predatory Lending Indicators](#142-predatory-lending-indicators)
- [14.3 Data Usage for Lending Decisions](#143-data-usage-for-lending-decisions)
- [14.4 Loan App Harassment Checklist](#144-loan-app-harassment-checklist)

---

Google Play has specific policies targeting predatory lending and aggressive debt collection practices, particularly in emerging markets.

### 14.1 Prohibited Contact/Harassment Practices

**Policy**: Loan apps must NOT:
- Access user's contact list for debt collection
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
- [ ] Emergency contact data used ONLY for loan application, NOT for collection
- [ ] Notification frequency is reasonable (not spamming overdue reminders)
- [ ] No threatening or shaming language in any UI or notification

### 14.2 Predatory Lending Indicators

Google flags apps that exhibit predatory lending patterns:

**Code audit**:
```bash
# Check for extremely short loan terms:
grep -rn "repayment.*day\|plazo.*dia\|term.*day\|loan.*period" --include="*.kt" --include="*.xml" -i
# Verify minimum repayment period >= 60 days

# Check for hidden fees:
grep -rn "fee\|cargo\|comision\|cuota.*manejo\|penalty\|penalidad\|recargo" --include="*.xml" --include="*.kt" -i

# Check for maximum APR disclosure:
grep -rn "APR\|tasa.*anual\|interest.*rate\|tasa.*interes" --include="*.xml" --include="*.kt" -i
```

- [ ] Minimum loan repayment period >= 60 days (< 60 days = **BLOCKER**)
- [ ] All fees clearly disclosed before loan agreement
- [ ] APR clearly displayed and not misleading
- [ ] No hidden fees or charges added after loan agreement
- [ ] No excessive late payment penalties

### 14.3 Data Usage for Lending Decisions

**Policy**: Loan apps must NOT use certain data types for credit scoring or lending decisions:

| Data Type | Use for Credit Scoring | Policy |
|-----------|----------------------|--------|
| SMS content | PROHIBITED | Spyware Policy |
| Contact list | PROHIBITED | Personal Loans Policy |
| Installed apps | PROHIBITED | QUERY_ALL_PACKAGES Policy |
| Photos/media | PROHIBITED | Personal Loans Policy |
| Fine location | PROHIBITED | Personal Loans Policy |
| Coarse location | ALLOWED with disclosure | Must declare in Data Safety |
| Device ID | ALLOWED with disclosure | Must declare in Data Safety |
| Financial records (credit bureau) | ALLOWED | Standard practice |

**Code audit**:
```bash
# Check if SMS data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "sms\|message"

# Check if app list flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "app\|package\|install"

# Check if contact data flows to risk assessment:
grep -rn "risk\|score\|credit\|assess\|evalua" --include="*.kt" -i | grep -i "contact"
```

- [ ] SMS data NOT used for credit scoring (even if collected for other purposes)
- [ ] Installed app data NOT used for credit scoring
- [ ] Contact data NOT used for credit scoring
- [ ] Photos/media NOT used for credit scoring
- [ ] Fine location NOT used for credit scoring

### 14.4 Loan App Harassment Checklist

- [ ] No contact list access for debt collection
- [ ] No automated communication to user's contacts
- [ ] Emergency contacts protected from collection use
- [ ] Reasonable notification frequency
- [ ] No threatening or shaming language
- [ ] Loan terms >= 60 days minimum
- [ ] All fees disclosed upfront
- [ ] Prohibited data types not used for lending decisions
