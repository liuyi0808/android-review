#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURE=$(mktemp -d)
trap 'rm -rf -- "$FIXTURE"' EXIT
mkdir -p "$FIXTURE/app/src/main"
MANIFEST="$FIXTURE/app/src/main/AndroidManifest.xml"

printf '%s\n' '<manifest xmlns:android="http://schemas.android.com/apk/res/android" />' > "$MANIFEST"
output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE")
[[ "$output" == *'Total findings: 0'* ]]
[[ "$output" != *'Possible AppFunctions exposure'* ]]

printf '%s\n' \
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools">' \
    '<uses-permission android:name="android.permission.READ_SMS" />' \
    '<uses-permission android:name="android.permission.READ_CALL_LOG" />' \
    '<uses-permission android:name="android.permission.READ_CONTACTS" tools:node="remove" />' \
    '<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />' \
    '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"' \
    '    android:usesPermissionFlags="onlyForLocationButton" />' \
    '<uses-permission android:name="android.permission.ACCESS_LOCAL_NETWORK" />' \
    '<uses-permission android:name="android.permission.MANAGE_CONTACTS" />' \
    '<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />' \
    '</manifest>' > "$MANIFEST"
printf '%s\n' \
    'import androidx.appfunctions.AppFunction' \
    '@AppFunction(isEnabled = true)' \
    'fun requestLoan(): Unit = Unit' \
    'fun onUserAction(node: AccessibilityNodeInfo): Unit = run { node.performAction(AccessibilityNodeInfo.ACTION_CLICK) }' \
    'fun loadReference(): Unit = run { ContactsContract.Contacts.CONTENT_URI }' \
    > "$FIXTURE/app/src/main/LoanExample.kt"
printf '%s\n' 'android { defaultConfig { targetSdk = 35 } }' > "$FIXTURE/app/build.gradle.kts"
mkdir -p "$FIXTURE/gradle" "$FIXTURE/app/src/main/jniLibs/arm64-v8a"
printf '%s\n' 'billing = { module = "com.android.billingclient:billing-ktx", version = "7.1.1" }' > "$FIXTURE/gradle/libs.versions.toml"
touch "$FIXTURE/app/src/main/jniLibs/arm64-v8a/libkyc_fixture.so"

output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE")
for check in 'SMS/Call Log permissions' 'Loan-policy permission candidates' 'Precise location evidence' \
    'Conditional local network/contact management' 'All Files Access' \
    'Possible AppFunctions exposure' 'Accessibility service evidence' 'Contact data access' \
    'targetSdk source evidence' 'Play Billing dependency evidence' 'Native library source evidence'; do
    if [[ "$output" != *"[NEEDS_CONFIRMATION] $check"* ]]; then
        printf 'Missing evidence-only check: %s\n%s\n' "$check" "$output" >&2
        exit 1
    fi
done
[[ "$output" == *'BLOCKER findings: 0'* ]]
[[ "$output" == *'READ_MEDIA_VIDEO'* && "$output" == *'ACCESS_FINE_LOCATION'* ]]
[[ "$output" == *'android:usesPermissionFlags="onlyForLocationButton"'* ]]

printf '%s\n' 'PASS: clean scan and evidence-only loan and build policy leads'

# Cover KaLoan's multiline removal markers, namespace aliases and generated-code false positive.
cat > "$MANIFEST" <<'XML'
<manifest xmlns:a="http://schemas.android.com/apk/res/android"
          xmlns:t="http://schemas.android.com/tools">
    <!-- <uses-permission a:name="android.permission.QUERY_ALL_PACKAGES" /> -->
    <uses-permission
        a:name="android.permission.READ_CALL_LOG"
        t:node="remove" />
    <uses-permission a:name="android.permission.READ_CONTACTS" t:node="remove" t:selector="sample.sdk" />
    <uses-permission t:node="removeAll" />
    <uses-permission a:name="android.permission.ACCESS_FINE_LOCATION" t:node="remove" />
    <uses-permission a:name="android.permission.READ_SMS" />
    <permission a:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
</manifest>
XML
mkdir -p "$FIXTURE/app/build/generated/source/proto/debug" "$FIXTURE/app/src/test"
cat > "$FIXTURE/app/build/generated/source/proto/debug/UserProfile.java" <<'JAVA'
private String token_ = "";
public String getToken() { return token_; }
private static final String API_KEY = "fixture-generated-only";
JAVA
printf '%s\n' 'val apiKey = "fixture-test-only"' > "$FIXTURE/app/src/test/FakeCredentials.kt"
cat > "$FIXTURE/app/src/main/CredentialExamples.kt" <<'KOTLIN'
// val apiKey = "fixture-comment-only"
val token: String = session.token
val tokenAlias = "accessToken"
val token = "token"
val password = ""
val clientSecret = "${project.secret}"
val authToken = "Bearer " + currentSession()
fun preview() = PasswordScreen(password = "fixture-preview-value")
KOTLIN
cat >> "$FIXTURE/app/build.gradle.kts" <<'GRADLE'
storePassword = System.getenv("STORE_PASSWORD")
keyPassword = providers.gradleProperty("uploadKeyPassword").orNull
buildConfigField("String", "API_KEY", "\"fixture-embedded-config\"")
GRADLE
output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE")
[[ "$output" == *'[INFO] Permission removal directives'* ]]
[[ "$output" == *'[NEEDS_CONFIRMATION] SMS/Call Log permissions'* && "$output" == *'android.permission.READ_SMS'* ]]
[[ "$output" == *'[NEEDS_CONFIRMATION] Embedded BuildConfig credential-like literals'* ]]
[[ "$output" == *'BLOCKER findings: 0'* ]]
for unexpected in 'Loan-policy permission candidates' 'Precise location evidence' 'All Files Access' \
    'QUERY_ALL_PACKAGES' 'UserProfile.java' 'CredentialExamples.kt' 'fixture-'; do
    [[ "$output" != *"$unexpected"* ]] || { printf 'Unexpected source result: %s\n' "$unexpected" >&2; exit 1; }
done

# Explicit variant evidence can confirm SDK/overlay additions even with source removal markers.
VARIANT="$FIXTURE/app/build/merged manifest.xml"
cat > "$VARIANT" <<'XML'
<manifest xmlns:a="http://schemas.android.com/apk/res/android">
    <uses-permission-sdk-23 a:name="android.permission.READ_CONTACTS" />
    <uses-permission a:name="android.permission.QUERY_ALL_PACKAGES" />
</manifest>
XML
output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE" --manifest "$VARIANT")
[[ "$output" == *'Supplied variant manifest'* && "$output" == *'[NEEDS_CONFIRMATION] Loan-policy permission candidates'* ]]
[[ "$output" == *'android.permission.READ_CONTACTS'* && "$output" == *'android.permission.QUERY_ALL_PACKAGES'* ]]
[[ "$output" != *'Permission removal directives'* && "$output" != *'READ_SMS'* ]]

# Positive literal cases must still fail CI, including Gradle signing and nested source modules.
MODULE="$FIXTURE/feature's source"
mkdir -p "$MODULE/src/main"
cat > "$MODULE/src/main/RealCredential.kt" <<'KOTLIN'
val apiKey: String =
    "fixture-source-secret"
fun log() = Log.i("Demo", apiKey)
KOTLIN
cat > "$MODULE/build.gradle" <<'GRADLE'
storePassword 'fixture-signing-secret'
GRADLE
cat >> "$FIXTURE/app/src/main/CredentialExamples.kt" <<'KOTLIN'
val clientSecret = "fixture-log-secret"; Log.i("tag", "fixture-context.kt:123:output")
KOTLIN
status=0
output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE" --manifest "$VARIANT") || status=$?
[[ "$status" == 1 && "$output" == *'BLOCKER findings: 2'* ]]
[[ "$output" == *'RealCredential.kt:1 [literal redacted]'* && "$output" == *'build.gradle:1 [literal redacted]'* ]]
[[ "$output" != *'fixture-'* ]]

# Missing arguments and malformed variant XML must have their own exit status.
status=0
output=$(bash "$SCRIPT_DIR/audit.sh" 2>&1) || status=$?
[[ "$status" == 2 && "$output" == *'Usage:'* ]]
printf '%s\n' '<manifest><uses-permission>' > "$VARIANT"
status=0
output=$(bash "$SCRIPT_DIR/audit.sh" "$FIXTURE" --manifest "$VARIANT" 2>&1) || status=$?
[[ "$status" == 2 && "$output" == *'Cannot read manifest evidence'* ]]

printf '%s\n' 'PASS: source removals, supplied variant evidence, credential redaction and exit codes'
