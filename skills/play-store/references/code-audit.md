# Code-Level Audit Checklist

## Table of Contents
- [18.1 Manifest Audit](#181-manifest-audit)
- [18.2 Code Audit](#182-code-audit)
- [18.3 Build Config Audit](#183-build-config-audit)
- [18.4 Spyware & Consent Flow Audit](#184-spyware--consent-flow-audit)
- [18.5 Device Abuse Audit](#185-device-abuse-audit)
- [18.6 Loan App Harassment Audit](#186-loan-app-harassment-audit)

---

Run these checks against your codebase before submission:

### 18.1 Manifest Audit

```bash
# SMS/Call Log permissions — requires Permissions Declaration Form and exception approval:
grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|READ_CALL_LOG\|WRITE_CALL_LOG" AndroidManifest.xml

# BLOCKER for personal loan apps — explicitly prohibited by Personal Loans policy:
grep -n "READ_CONTACTS\|WRITE_CONTACTS\|READ_PHONE_NUMBERS" AndroidManifest.xml
grep -n "QUERY_ALL_PACKAGES" AndroidManifest.xml

# Photo/Video permissions (need declaration):
grep -n "READ_MEDIA_IMAGES\|READ_MEDIA_VIDEO\|READ_EXTERNAL_STORAGE" AndroidManifest.xml

# Foreground service type check:
grep -n "<service" AndroidManifest.xml | grep -v "foregroundServiceType"

# Exported components without protection:
grep -n "exported=\"true\"" AndroidManifest.xml

# Backup configuration:
grep -n "allowBackup" AndroidManifest.xml
```

### 18.2 Code Audit

```bash
# Debug logging in production — USE CONTEXT-AWARE CHECK (see Section 1.4 methodology):
# WRONG: grep -rn "Log\.\(d\|v\|i\)\(" --include="*.kt" app/src/main/ | grep -v "BuildConfig.DEBUG"
#   ^^^ This produces FALSE POSITIVES when BuildConfig.DEBUG guard is on the line above!
#
# CORRECT: Check with surrounding context, then manually verify each match:
grep -rn -B 3 "Log\.\(d\|v\|i\)\(" --include="*.kt" app/src/main/
# For each match: verify if (BuildConfig.DEBUG) exists within 1-3 lines above.
# Only flag matches where NO guard is found in the context window.

# Unguarded printStackTrace() — same context-aware approach:
grep -rn -B 3 "printStackTrace" --include="*.kt" app/src/main/
# Verify each has BuildConfig.DEBUG guard within 1-3 lines above.

# Hardcoded secrets:
grep -rn "apiKey\|api_key\|secret\|password\|token" --include="*.kt" --include="*.gradle*" | grep -v "BuildConfig\." | grep -v "test/"

# Sensitive data in URLs:
grep -rn "token=\|key=\|password=\|secret=" --include="*.kt" app/src/main/

# Device ID collection (must be declared in Data Safety):
grep -rn "ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId" --include="*.kt"

# SMS content access (requires exception approval; PROHIBITED for credit scoring in loan apps):
grep -rn "Telephony.Sms\|SmsMessage\|pdus" --include="*.kt"

# Installed apps enumeration:
grep -rn "getInstalledPackages\|getInstalledApplications\|queryIntentActivities" --include="*.kt"
```

### 18.3 Build Config Audit

```bash
# Check targetSdk:
grep -rn "targetSdk\|targetSdkVersion" --include="*.gradle*"

# Check minify/shrink:
grep -rn "minifyEnabled\|shrinkResources" --include="*.gradle*"

# Check signing configs for hardcoded values:
grep -rn "storePassword\|keyPassword" --include="*.gradle*"

# Check for debug-only code that might leak to release:
grep -rn "BuildConfig.DEBUG" --include="*.kt" -c
```

---

### 18.4 Spyware & Consent Flow Audit

```bash
# Consent dialog — does "decline" actually prevent data collection?
grep -rn "okListener\|confirmListener\|agreeListener" --include="*.kt" -A 3
grep -rn "refuseListener\|cancelListener\|declineListener" --include="*.kt" -A 3

# SDK initialization before consent (BLOCKER if found):
grep -rn "class.*Application.*:" --include="*.kt" -l
# Then check each Application class for SDK init in onCreate()

grep -rn "AppsFlyerLib.*init\|AppsFlyerLib.*start" --include="*.kt"
grep -rn "FirebaseApp.initializeApp" --include="*.kt"
grep -rn "FacebookSdk.*initialize" --include="*.kt"

# SMS body content upload check:
grep -rn "SP_BODY\|sms_body\|message_body" --include="*.kt" | grep -i "add\|put\|property"

# Incremental/continuous SMS harvesting:
grep -rn "SMS_SUCCESS_TIME\|last.*sms.*time\|sms.*timestamp" --include="*.kt"

# SMS filtering adequacy — check SQL LIKE patterns:
grep -rn "LIKE\|like" --include="*.kt" | grep -i "sms\|body\|message"
```

### 18.5 Device Abuse Audit

```bash
# Device settings modification:
grep -rn "Settings.System\|Settings.Secure\|Settings.Global" --include="*.kt" | grep -i "put\|write\|set"

# Accessibility service abuse:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt"

# Device admin / preventing uninstall:
grep -rn "DeviceAdminReceiver\|DevicePolicyManager\|BIND_DEVICE_ADMIN" --include="*.kt" --include="*.xml"

# Remote code execution (CRITICAL):
grep -rn "DexClassLoader\|PathClassLoader\|InMemoryDexClassLoader" --include="*.kt"
grep -rn "Runtime.getRuntime().exec\|ProcessBuilder" --include="*.kt"

# System UI mimicry:
grep -rn "AlertDialog" --include="*.kt" | grep -i "system\|update\|warning\|virus\|security"
```

### 18.6 Loan App Harassment Audit

```bash
# Contact list access for collection:
grep -rn "ContactsContract\|READ_CONTACTS" --include="*.kt"

# Automated SMS/calling to contacts:
grep -rn "SmsManager\|sendTextMessage" --include="*.kt"
grep -rn "ACTION_CALL\b" --include="*.kt"

# Debt collection language:
grep -rn "cobro\|cobranza\|mora\|deuda\|vencido\|atrasado" --include="*.xml" --include="*.kt" -i

# Aggressive notification scheduling:
grep -rn "NotificationManager\|NotificationCompat" --include="*.kt" | grep -i "overdue\|payment\|remind\|cobr"

# Data used for credit scoring (should NOT include SMS, apps, contacts):
grep -rn "risk\|score\|credit\|assess" --include="*.kt" -i | grep -i "sms\|message\|app\|package\|contact"
```
