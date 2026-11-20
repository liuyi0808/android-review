#!/usr/bin/env bash
# Google Play Code Audit Script
# Wraps the grep-based audit commands from references/code-audit.md
# into a single executable report.
#
# Usage: ./audit.sh <project-root-path> [--manifest <variant-manifest.xml>]
# Requires Bash and Python 3 (standard library only).
#
# Exit codes:
#   0 = no automated blockers (manual review may still be required)
#   1 = one or more automated blockers
#   2 = invalid arguments or evidence could not be read

set -euo pipefail

usage() {
    printf 'Usage: %s <project-root-path> [--manifest <variant-manifest.xml>]\n' "$0" >&2
    exit 2
}

if [[ $# -ne 1 && $# -ne 3 ]]; then
    usage
fi
PROJECT_ROOT="$1"
if [[ ! -d "$PROJECT_ROOT" ]]; then
    printf 'ERROR: Directory not found: %s\n' "$PROJECT_ROOT" >&2
    exit 2
fi
PROJECT_ROOT=$(cd -- "$PROJECT_ROOT" && pwd -P)
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd -P)

if ! command -v python3 >/dev/null 2>&1; then
    echo 'ERROR: Python 3 is required for XML and literal-credential checks.' >&2
    exit 2
fi

if [[ $# -eq 3 ]]; then
    [[ "$2" == --manifest ]] || usage
    if [[ ! -f "$3" ]]; then
        printf 'ERROR: Manifest file not found: %s\n' "$3" >&2
        exit 2
    fi
    MANIFESTS="$3"
    MANIFEST_SCOPE='Supplied variant manifest (confirm that it matches the audited build)'
else
    MANIFESTS=$(find "$PROJECT_ROOT" -type d \( -name build -o -name generated \
        -o -name .git -o -name .gradle -o -name node_modules \) -prune \
        -o -type f -name AndroidManifest.xml -path '*/src/main/*' -print) || exit 2
    MANIFEST_SCOPE='Source manifests only (variant and dependency merging still require verification)'
fi
CREDENTIAL_EVIDENCE=$(python3 "$SCRIPT_DIR/audit_evidence.py" credentials "$PROJECT_ROOT") || exit 2

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
        # Keep grep output location-only so report logs cannot expose source values.
        case "$1" in
            grep|bash) output=$(printf '%s\n' "$output" | sed -E 's/(^|:)([0-9]+):.*/\1\2/') ;;
        esac
        printf '%s\n' "$output" | sed 's/^/    /'
        echo ""
    fi
}

select_evidence() {
    printf '%s\n' "$1" | awk -v kind="$2" 'index($0, kind "\t") == 1 { print substr($0, length(kind) + 2) }'
}

select_permission() {
    grep -E -- "$2" <<< "$1"
}

print_header "Google Play Code Audit Report"
echo "Project: $PROJECT_ROOT"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================
# 18.1 Manifest Audit
# ============================================================
print_section "18.1 Manifest Audit"

echo "  Evidence: $MANIFEST_SCOPE"
if [ -n "$MANIFESTS" ]; then
    while IFS= read -r manifest; do
        echo "  Scanning: $manifest"
        manifest_evidence=$(python3 "$SCRIPT_DIR/audit_evidence.py" manifest "$manifest") || exit 2
        permissions=$(select_evidence "$manifest_evidence" declared)

        run_check "Permission removal directives (review merge scope)" "INFO" \
            select_evidence "$manifest_evidence" removed

        run_check "SMS/Call Log permissions (verify runtime purpose and Play Console eligibility/approval)" "NEEDS_CONFIRMATION" \
            select_permission "$permissions" 'android\.permission\.(READ_SMS|SEND_SMS|RECEIVE_SMS|RECEIVE_MMS|RECEIVE_WAP_PUSH|WRITE_SMS|READ_CALL_LOG|WRITE_CALL_LOG|PROCESS_OUTGOING_CALLS)( |$)'

        run_check "Loan-policy permission candidates (verify category and submitted merged manifest)" "NEEDS_CONFIRMATION" \
            select_permission "$permissions" 'android\.permission\.(READ_CONTACTS|READ_PHONE_NUMBERS|ACCESS_FINE_LOCATION|READ_MEDIA_IMAGES|READ_MEDIA_VIDEO|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|QUERY_ALL_PACKAGES)( |$)'

        run_check "Precise location evidence (verify effective permission, button flag, runtime scope and Console declaration)" "NEEDS_CONFIRMATION" \
            select_permission "$permissions" 'android\.permission\.ACCESS_FINE_LOCATION( |$)'

        run_check "Conditional local network/contact management (verify target SDK, policy date, alternatives and declaration)" "NEEDS_CONFIRMATION" \
            select_permission "$permissions" 'android\.permission\.(ACCESS_LOCAL_NETWORK|MANAGE_CONTACTS)( |$)'

        run_check "All Files Access (verify core use, third-party purpose, scoped alternatives and declaration)" "NEEDS_CONFIRMATION" \
            select_permission "$permissions" 'android\.permission\.MANAGE_EXTERNAL_STORAGE( |$)'

        run_check "Foreground service without type" "WARNING" \
            bash -c 'grep -n "<service" -- "$1" | grep -v "foregroundServiceType"' _ "$manifest"

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

run_check "Hardcoded credential literals (verify purpose; values redacted)" "BLOCKER" \
    select_evidence "$CREDENTIAL_EVIDENCE" credential

run_check "Embedded BuildConfig credential-like literals (verify use and privilege; values redacted)" "NEEDS_CONFIRMATION" \
    select_evidence "$CREDENTIAL_EVIDENCE" embedded

run_check "Possible AppFunctions exposure (verify published schema, behavior and Data Safety)" "NEEDS_CONFIRMATION" \
    grep -rEn 'androidx\.appfunctions|@AppFunction([[:space:](]|$)' --include='*.kt' --include='*.java' --include='*.gradle' --include='*.gradle.kts' "$PROJECT_ROOT"

if [ -d "$SRC_DIR" ]; then
    # Inspect guard context locally at the reported locations.
    run_check "Debug logging (review context for BuildConfig.DEBUG guard)" "WARNING" \
        grep -rEn 'Log\.(d|v|i)\(' --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "printStackTrace (verify BuildConfig.DEBUG guard)" "WARNING" \
        grep -rn "printStackTrace" --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "Sensitive data in URLs" "BLOCKER" \
        grep -rn 'token=\|key=\|password=\|secret=' --include="*.kt" --include="*.java" "$SRC_DIR"

    run_check "Device ID collection (must declare in Data Safety)" "WARNING" \
        grep -rn 'ANDROID_ID\|getAdvertisingIdInfo\|MediaDrm\|IMEI\|getDeviceId' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "SMS content access detected (apply spyware-policy.md §11.4 two-gate review)" "INFO" \
        grep -rn 'Telephony.Sms\|SmsMessage\|pdus' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "Installed apps enumeration" "WARNING" \
        grep -rn 'getInstalledPackages\|getInstalledApplications\|queryIntentActivities' --include="*.kt" --include="*.java" "$PROJECT_ROOT"
else
    echo "  WARNING: Source directory not found at $SRC_DIR"
    echo "  Searching project-wide for source files..."

    run_check "Debug logging (review context for BuildConfig.DEBUG guard)" "WARNING" \
        grep -rEn 'Log\.(d|v|i)\(' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

    run_check "SMS content access detected (apply spyware-policy.md §11.4 two-gate review)" "INFO" \
        grep -rn 'Telephony.Sms\|SmsMessage\|pdus' --include="*.kt" --include="*.java" "$PROJECT_ROOT"
fi

# ============================================================
# 18.3 Build Config Audit
# ============================================================
print_section "18.3 Build Config Audit"

run_check "targetSdk source evidence (verify submitted manifest and submission or availability threshold)" "NEEDS_CONFIRMATION" \
    grep -rn --binary-files=without-match 'targetSdk\|targetSdkVersion' --include="*.gradle.kts" --include="*.gradle" "$PROJECT_ROOT"

run_check "Play Billing dependency evidence (verify the submitted variant's resolved version)" "NEEDS_CONFIRMATION" \
    grep -rnF 'com.android.billingclient' --include='*.gradle' --include='*.gradle.kts' --include='*.toml' "$PROJECT_ROOT"

run_check "Native library source evidence (verify the actual bundle and 16 KB compatibility)" "NEEDS_CONFIRMATION" \
    find "$PROJECT_ROOT" -type f -path '*/src/*/jniLibs/*.so'

run_check "Minify/Shrink configuration" "INFO" \
    grep -rn --binary-files=without-match 'minifyEnabled\|isMinifyEnabled\|shrinkResources\|isShrinkResources' --include="*.gradle.kts" --include="*.gradle" "$PROJECT_ROOT"

run_check "Hardcoded signing password literals (values redacted)" "BLOCKER" \
    select_evidence "$CREDENTIAL_EVIDENCE" signing

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

run_check "SMS body content upload path detected (apply spyware-policy.md §11.4 two-gate review)" "INFO" \
    bash -c 'grep -rEn "SP_BODY|sms_body|message_body" --include="*.kt" --include="*.java" -- "$1" | grep -Ei "add|put|property"' _ "$PROJECT_ROOT"

# ============================================================
# 18.5 Device Abuse Audit
# ============================================================
print_section "18.5 Device Abuse Audit"

run_check "Device settings modification" "BLOCKER" \
    bash -c 'grep -rEn "Settings.System|Settings.Secure|Settings.Global" --include="*.kt" --include="*.java" -- "$1" | grep -Ei "put|write|set"' _ "$PROJECT_ROOT"

run_check "Accessibility service evidence (verify applicable Console approval, designation, disclosure, consent and behavior)" "NEEDS_CONFIRMATION" \
    grep -rEn 'AccessibilityService|BIND_ACCESSIBILITY_SERVICE|isAccessibilityTool|AccessibilityNodeInfo.*ACTION_|performGlobalAction|dispatchGesture|GestureDescription|getRootInActiveWindow' --include="*.xml" --include="*.kt" --include="*.java" "$PROJECT_ROOT"

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

run_check "Contact data access (distinguish picker-scoped data from broad reads; trace lending/collection use)" "NEEDS_CONFIRMATION" \
    grep -rn 'ContactsContract\|READ_CONTACTS' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Possible programmatic SMS (verify actual recipients and purpose)" "NEEDS_CONFIRMATION" \
    grep -rn 'SmsManager\|sendTextMessage' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Possible direct calling (verify actual recipients and purpose)" "NEEDS_CONFIRMATION" \
    grep -rn 'ACTION_CALL\b' --include="*.kt" --include="*.java" "$PROJECT_ROOT"

run_check "Possible sensitive inputs to credit scoring (trace data to decision)" "NEEDS_CONFIRMATION" \
    bash -c 'grep -rEin "risk|score|credit|assess" --include="*.kt" --include="*.java" -- "$1" | grep -Ei "sms|message|app|package|contact"' _ "$PROJECT_ROOT"

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
    echo "No BLOCKER items from this scan. Review NEEDS_CONFIRMATION/WARNING/INFO findings above."
fi
echo ""
