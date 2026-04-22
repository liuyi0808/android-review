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
grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|RECEIVE_MMS\|RECEIVE_WAP_PUSH\|WRITE_SMS\|READ_CALL_LOG\|WRITE_CALL_LOG\|PROCESS_OUTGOING_CALLS" AndroidManifest.xml

# BLOCKER for personal loan apps — explicitly prohibited by Personal Loans policy:
grep -n "READ_CONTACTS\|READ_PHONE_NUMBERS" AndroidManifest.xml
grep -n "QUERY_ALL_PACKAGES" AndroidManifest.xml

# Contacts Permissions Policy (effective 2026-10-28, Android 17+ / API 37+):
# Direct ContactsContract query indicates broad access, not Contact Picker.
grep -rn "ContactsContract\.Contacts\.CONTENT_URI\|CommonDataKinds\.Phone\.CONTENT_URI" --include="*.kt" --include="*.java"
grep -rn "ActivityResultContracts\.PickContact\|ACTION_PICK.*Contacts" --include="*.kt" --include="*.java"
# — If READ_CONTACTS is declared but Contact Picker is not used, broad access must be justified via Play Developer Declaration.

# Location button flag (required for one-time precise location, Android 17+, effective ~2026-05-15):
grep -n "onlyForLocationButton" AndroidManifest.xml
grep -n "ACCESS_FINE_LOCATION" AndroidManifest.xml
# — FINE_LOCATION without onlyForLocationButton flag and without persistent-location declaration = policy risk.

# Geofencing via FGS (removed from approved FGS use cases 2026-04-15):
grep -rn "GeofencingClient\|addGeofences" --include="*.kt" --include="*.java"
grep -n "FOREGROUND_SERVICE_LOCATION\|foregroundServiceType=\"location\"" AndroidManifest.xml
# — If GeofencingClient is used alongside a location FGS, confirm FGS is not the geofencing transport; use Geofence API directly.

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
# WRONG: grep -rn "Log\.\(d\|v\|i\)\(" --include="*.kt" --include="*.java" app/src/main/ | grep -v "BuildConfig.DEBUG"
#   ^^^ This produces FALSE POSITIVES when BuildConfig.DEBUG guard is on the line above!
#
# CORRECT: Check with surrounding context, then manually verify each match:
grep -rn -B 3 "Log\.\(d\|v\|i\)\(" --include="*.kt" --include="*.java" app/src/main/
# For each match: verify if (BuildConfig.DEBUG) exists within 1-3 lines above.
# Only flag matches where NO guard is found in the context window.

# Unguarded printStackTrace() — same context-aware approach:
grep -rn -B 3 "printStackTrace" --include="*.kt" --include="*.java" app/src/main/
# Verify each has BuildConfig.DEBUG guard within 1-3 lines above.

# Hardcoded secrets:
grep -rn "apiKey\|api_key\|secret\|password\|token" --include="*.kt" --include="*.java" --include="*.gradle*" | grep -v "BuildConfig\." | grep -v "test/"

# Sensitive data in URLs:
grep -rn "token=\|key=\|password=\|secret=" --include="*.kt" --include="*.java" app/src/main/

# Device ID collection (must be declared in Data Safety):
grep -rn "ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId" --include="*.kt" --include="*.java"

# SMS content access (requires exception approval; must comply with Spyware Policy):
grep -rn "Telephony.Sms\|SmsMessage\|pdus\|content://sms" --include="*.kt" --include="*.java"

# Installed apps enumeration:
grep -rn "getInstalledPackages\|getInstalledApplications\|queryIntentActivities" --include="*.kt" --include="*.java"
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
grep -rn "BuildConfig.DEBUG" --include="*.kt" --include="*.java" -c
```

---

### 18.4 Spyware & Consent Flow Audit

```bash
# Consent dialog — does "decline" actually prevent data collection?
grep -rn "okListener\|confirmListener\|agreeListener" --include="*.kt" --include="*.java" -A 3
grep -rn "refuseListener\|cancelListener\|declineListener" --include="*.kt" --include="*.java" -A 3

# SDK initialization before consent (BLOCKER if found):
grep -rn "class.*Application.*:" --include="*.kt" --include="*.java" -l
# Then check each Application class for SDK init in onCreate()

grep -rn "AppsFlyerLib.*init\|AppsFlyerLib.*start" --include="*.kt" --include="*.java"
grep -rn "FirebaseApp.initializeApp" --include="*.kt" --include="*.java"
grep -rn "FacebookSdk.*initialize" --include="*.kt" --include="*.java"

# SMS body content upload — verify only financial SMS is uploaded, with user consent:
# (Not an absolute blocker per policy; violation only if non-financial/personal SMS is transmitted
#  or transmission is without policy compliant functionality / unexpected to user)
grep -rn "SP_BODY\|sms_body\|message_body" --include="*.kt" --include="*.java" | grep -i "add\|put\|property"

# Incremental/continuous SMS harvesting:
grep -rn "SMS_SUCCESS_TIME\|last.*sms.*time\|sms.*timestamp" --include="*.kt" --include="*.java"

# SMS filtering adequacy — check SQL LIKE patterns:
grep -rn "LIKE\|like" --include="*.kt" --include="*.java" | grep -i "sms\|body\|message"
```

### 18.5 Device Abuse Audit

```bash
# Device settings modification:
grep -rn "Settings.System\|Settings.Secure\|Settings.Global" --include="*.kt" --include="*.java" | grep -i "put\|write\|set"

# Accessibility service abuse:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt" --include="*.java"

# Accessibility autonomous actions (PROHIBITED since Oct 2025):
grep -rn "performAction\|performGlobalAction\|dispatchGesture" --include="*.kt" --include="*.java"
grep -rn "AccessibilityNodeInfo.*ACTION_" --include="*.kt" --include="*.java"
grep -rn "GestureDescription\|StrokeDescription" --include="*.kt" --include="*.java"
grep -rn "getRootInActiveWindow\|getWindows" --include="*.kt" --include="*.java"

# Device admin / preventing uninstall:
grep -rn "DeviceAdminReceiver\|DevicePolicyManager\|BIND_DEVICE_ADMIN" --include="*.kt" --include="*.java" --include="*.xml"

# Remote code execution (CRITICAL):
grep -rn "DexClassLoader\|PathClassLoader\|InMemoryDexClassLoader" --include="*.kt" --include="*.java"
grep -rn "Runtime.getRuntime().exec\|ProcessBuilder" --include="*.kt" --include="*.java"

# System UI mimicry:
grep -rn "AlertDialog" --include="*.kt" --include="*.java" | grep -i "system\|update\|warning\|virus\|security"

# FLAG_SECURE compliance (all apps must respect FLAG_SECURE):
grep -rn "MediaProjection\|createScreenCapture\|PixelCopy" --include="*.kt" --include="*.java"
grep -rn "FLAG_SECURE.*clear\|clearFlags.*FLAG_SECURE" --include="*.kt" --include="*.java"
grep -rn "MediaRecorder.*setVideoSource\|createVirtualDisplay" --include="*.kt" --include="*.java"
```

### 18.6 Loan App Harassment Audit

```bash
# Contact list access for collection:
grep -rn "ContactsContract\|READ_CONTACTS" --include="*.kt" --include="*.java"

# Automated SMS/calling to contacts:
grep -rn "SmsManager\|sendTextMessage" --include="*.kt" --include="*.java"
grep -rn "ACTION_CALL\b" --include="*.kt" --include="*.java"

# Debt collection language:
grep -rn "cobro\|cobranza\|mora\|deuda\|vencido\|atrasado" --include="*.xml" --include="*.kt" --include="*.java" -i

# Aggressive notification scheduling:
grep -rn "NotificationManager\|NotificationCompat" --include="*.kt" --include="*.java" | grep -i "overdue\|payment\|remind\|cobr"

# Data used for credit scoring (should NOT include SMS, apps, contacts):
grep -rn "risk\|score\|credit\|assess" --include="*.kt" --include="*.java" -i | grep -i "sms\|message\|app\|package\|contact"
```
