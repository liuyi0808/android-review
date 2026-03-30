#!/usr/bin/env bash
# Google Play Code Audit Script
# Wraps the grep-based audit commands from references/code-audit.md
# into a single executable report.
#
# Usage: ./audit.sh <project-root-path>
# Example: ./audit.sh ~/Documents/AIWork/Project1
#
# Exit codes:
#   0 = no BLOCKER findings
#   1 = one or more BLOCKER findings (CI/CD should fail)

set -euo pipefail

PROJECT_ROOT="${1:?Usage: ./audit.sh <project-root-path>}"

if [ ! -d "$PROJECT_ROOT" ]; then
    echo "ERROR: Directory not found: $PROJECT_ROOT"
    exit 1
fi

# Multi-module manifest discovery (supports standard and multi-module projects)
MANIFESTS=$(find "$PROJECT_ROOT" -name "AndroidManifest.xml" -path "*/src/main/*" 2>/dev/null || true)
if [ -z "$MANIFESTS" ]; then
    echo "WARNING: No AndroidManifest.xml found under $PROJECT_ROOT"
fi

SRC_DIR="$PROJECT_ROOT/app/src/main"
TOTAL_FINDINGS=0
BLOCKER_FINDINGS=0

print_header() {
    echo ""
    echo "================================================================"
    echo "  $1"
    echo "================================================================"
}

print_section() {
    echo ""
    echo "--- $1 ---"
}

run_check() {
    local description="$1"
    local severity="$2"
    shift 2
    local output
    output=$("$@" 2>/dev/null || true)
    if [ -n "$output" ]; then
        TOTAL_FINDINGS=$((TOTAL_FINDINGS + 1))
        if [ "$severity" = "BLOCKER" ]; then
            BLOCKER_FINDINGS=$((BLOCKER_FINDINGS + 1))
        fi
        echo "  [$severity] $description"
        echo "$output" | sed 's/^/    /'
        echo ""
    fi
}

print_header "Google Play Code Audit Report"
echo "Project: $PROJECT_ROOT"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================
# 18.1 Manifest Audit
# ============================================================
print_section "18.1 Manifest Audit"

if [ -n "$MANIFESTS" ]; then
    while IFS= read -r manifest; do
        echo "  Scanning: $manifest"

        run_check "SMS/Call Log permissions (requires Declaration Form)" "BLOCKER" \
            grep -n "READ_SMS\|SEND_SMS\|RECEIVE_SMS\|RECEIVE_MMS\|RECEIVE_WAP_PUSH\|WRITE_SMS\|READ_CALL_LOG\|WRITE_CALL_LOG\|PROCESS_OUTGOING_CALLS" "$manifest"

        run_check "Contacts/Phone permissions (PROHIBITED for loan apps)" "BLOCKER" \
            grep -n "READ_CONTACTS\|WRITE_CONTACTS\|READ_PHONE_NUMBERS" "$manifest"

        run_check "QUERY_ALL_PACKAGES (requires declaration)" "WARNING" \
            grep -n "QUERY_ALL_PACKAGES" "$manifest"

        run_check "Photo/Video permissions (need declaration)" "WARNING" \
            grep -n "READ_MEDIA_IMAGES\|READ_MEDIA_VIDEO\|READ_EXTERNAL_STORAGE" "$manifest"

        run_check "Foreground service without type" "WARNING" \
            bash -c "grep -n '<service' '$manifest' | grep -v 'foregroundServiceType'"

        run_check "Exported components (verify protection)" "INFO" \
            grep -n 'exported="true"' "$manifest"

        run_check "Backup configuration" "INFO" \
            grep -n "allowBackup" "$manifest"
    done <<< "$MANIFESTS"
else
    echo "  WARNING: No AndroidManifest.xml found"
fi

# ============================================================
# 18.2 Code Audit
# ============================================================
print_section "18.2 Code Audit"

if [ -d "$SRC_DIR" ]; then
    # Context-aware log check: uses -B 3 to show surrounding lines for manual BuildConfig.DEBUG verification
    run_check "Debug logging (review context for BuildConfig.DEBUG guard)" "WARNING" \
        grep -rn -B 3 'Log\.\(d\|v\|i\)\(' --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "printStackTrace (verify BuildConfig.DEBUG guard)" "WARNING" \
        grep -rn -B 3 "printStackTrace" --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "Hardcoded secrets" "BLOCKER" \
        bash -c "grep -rn --binary-files=without-match 'apiKey\|api_key\|secret\|password\|token' --include='*.kt' --include='*.java' --include='*.gradle.kts' '$PROJECT_ROOT/app' | grep -v 'BuildConfig\.' | grep -v 'test/'"

    run_check "Sensitive data in URLs" "BLOCKER" \
        grep -rn 'token=\|key=\|password=\|secret=' --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "Device ID collection (must declare in Data Safety)" "WARNING" \
        grep -rn 'ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "SMS content access" "BLOCKER" \
        grep -rn 'Telephony.Sms\|SmsMessage\|pdus' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "Installed apps enumeration" "WARNING" \
        grep -rn 'getInstalledPackages\|getInstalledApplications\|queryIntentActivities' --include="*.kt" --include="*.java" "$PROJECT_ROOT"
else
    echo "  WARNING: Source directory not found at $SRC_DIR"
    echo "  Searching project-wide for source files..."

    run_check "Debug logging (review context for BuildConfig.DEBUG guard)" "WARNING" \
        grep -rn -B 3 'Log\.\(d\|v\|i\)\(' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "Hardcoded secrets" "BLOCKER" \
        bash -c "grep -rn --binary-files=without-match 'apiKey\|api_key\|secret\|password\|token' --include='*.kt' --include='*.java' --include='*.gradle.kts' '$PROJECT_ROOT' | grep -v 'BuildConfig\.' | grep -v 'test/'"

    run_check "SMS content access" "BLOCKER" \
        grep -rn 'Telephony.Sms\|SmsMessage\|pdus' --include="*.kt" --include="*.java" "$PROJECT_ROOT"
fi

# ============================================================
# 18.3 Build Config Audit
# ============================================================
print_section "18.3 Build Config Audit"

run_check "targetSdk version" "INFO" \
    grep -rn --binary-files=without-match 'targetSdk\|targetSdkVersion' --include="*.gradle.kts" --include="*.gradle" "$PROJECT_ROOT"

run_check "Minify/Shrink configuration" "INFO" \
    grep -rn --binary-files=without-match 'minifyEnabled\|isMinifyEnabled\|shrinkResources\|isShrinkResources' --include="*.gradle.kts" --include="*.gradle" "$PROJECT_ROOT"

run_check "Hardcoded signing passwords in gradle" "BLOCKER" \
    grep -rn --binary-files=without-match 'storePassword\|keyPassword' --include="*.gradle.kts" --include="*.gradle" "$PROJECT_ROOT"

# ============================================================
# 18.4 Spyware & Consent Flow Audit
# ============================================================
print_section "18.4 Spyware & Consent Flow Audit"

run_check "SDK init in Application class (verify consent order)" "WARNING" \
    grep -rn 'class.*Application.*:' --include="*.kt" --include="*.java" -l "$PROJECT_ROOT"

run_check "AppsFlyer init (must be after consent)" "WARNING" \
    grep -rn 'AppsFlyerLib.*init\|AppsFlyerLib.*start' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Firebase init (verify consent order)" "WARNING" \
    grep -rn 'FirebaseApp.initializeApp' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Facebook SDK init (must be after consent)" "WARNING" \
    grep -rn 'FacebookSdk.*initialize' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "SMS body content upload (verify only financial SMS, with consent)" "WARNING" \
    bash -c "grep -rn 'SP_BODY\|sms_body\|message_body' --include='*.kt' --include='*.java' '$PROJECT_ROOT' | grep -i 'add\|put\|property'"

# ============================================================
# 18.5 Device Abuse Audit
# ============================================================
print_section "18.5 Device Abuse Audit"

run_check "Device settings modification" "BLOCKER" \
    bash -c "grep -rn 'Settings.System\|Settings.Secure\|Settings.Global' --include='*.kt' --include='*.java' '$PROJECT_ROOT' | grep -i 'put\|write\|set'"

run_check "Accessibility service usage" "BLOCKER" \
    grep -rn 'AccessibilityService\|BIND_ACCESSIBILITY_SERVICE' --include="*.xml" --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Accessibility autonomous actions (PROHIBITED since Oct 2025)" "BLOCKER" \
    grep -rn 'performAction\|performGlobalAction\|dispatchGesture' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Accessibility ACTION_ constants usage" "BLOCKER" \
    grep -rn 'AccessibilityNodeInfo.*ACTION_' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Gesture injection (GestureDescription/StrokeDescription)" "BLOCKER" \
    grep -rn 'GestureDescription\|StrokeDescription' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Accessibility cross-app window reading" "BLOCKER" \
    grep -rn 'getRootInActiveWindow\|getWindows' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Device admin / prevent uninstall" "BLOCKER" \
    grep -rn 'DeviceAdminReceiver\|DevicePolicyManager\|BIND_DEVICE_ADMIN' --include="*.kt" --include="*.java" --include="*.xml" "$PROJECT_ROOT"

run_check "Dynamic code loading (CRITICAL)" "BLOCKER" \
    grep -rn 'DexClassLoader\|PathClassLoader\|InMemoryDexClassLoader' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Runtime command execution" "BLOCKER" \
    grep -rn 'Runtime.getRuntime().exec\|ProcessBuilder' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "FLAG_SECURE violation (screen capture of secure content)" "WARNING" \
    grep -rn 'MediaProjection\|createScreenCapture\|PixelCopy' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "FLAG_SECURE bypass attempt" "BLOCKER" \
    grep -rn 'FLAG_SECURE.*clear\|clearFlags.*FLAG_SECURE' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

# ============================================================
# 18.6 Loan App Harassment Audit
# ============================================================
print_section "18.6 Loan App Harassment Audit"

run_check "Contact list access" "BLOCKER" \
    grep -rn 'ContactsContract\|READ_CONTACTS' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Automated SMS sending" "BLOCKER" \
    grep -rn 'SmsManager\|sendTextMessage' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Automated calling" "BLOCKER" \
    grep -rn 'ACTION_CALL\b' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Prohibited credit scoring data (SMS, apps, contacts)" "BLOCKER" \
    bash -c "grep -rn 'risk\|score\|credit\|assess' --include='*.kt' --include='*.java' -i '$PROJECT_ROOT' | grep -i 'sms\|message\|app\|package\|contact'"

# ============================================================
# Summary
# ============================================================
print_header "Audit Summary"
echo "Total findings: $TOTAL_FINDINGS"
echo "BLOCKER findings: $BLOCKER_FINDINGS"
if [ "$TOTAL_FINDINGS" -eq 0 ]; then
    echo "No issues detected. Review manually before submission."
elif [ "$BLOCKER_FINDINGS" -gt 0 ]; then
    echo "BLOCKER items found — must be fixed before submission."
    exit 1
else
    echo "No BLOCKER items. Review WARNING/INFO findings above."
fi
echo ""
