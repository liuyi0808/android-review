# Device and Network Abuse

## Table of Contents
- [12.1 Device Settings Modification](#121-device-settings-modification)
- [12.2 Accessibility Service Abuse](#122-accessibility-service-abuse)
- [12.3 App Interference](#123-app-interference)
- [12.4 Network Abuse](#124-network-abuse)
- [12.5 FLAG_SECURE Compliance](#125-flag_secure-compliance)
- [12.6 Device Abuse Checklist](#126-device-abuse-checklist)

---

### 12.1 Device Settings Modification

Apps must NEVER modify device settings without explicit user consent and clear disclosure.

**Code audit**:
```bash
# Check for device settings writes:
grep -rn "Settings.System\|Settings.Secure\|Settings.Global" --include="*.kt" | grep -i "put\|write\|set"

# Check for WiFi/Bluetooth manipulation:
grep -rn "WifiManager.*setWifiEnabled\|BluetoothAdapter.*enable\|BluetoothAdapter.*disable" --include="*.kt"

# Check for volume/brightness changes:
grep -rn "AudioManager.*setStreamVolume\|SCREEN_BRIGHTNESS" --include="*.kt"

# Check for device admin capabilities:
grep -rn "DeviceAdminReceiver\|DevicePolicyManager" --include="*.kt" --include="*.xml"
grep -rn "BIND_DEVICE_ADMIN\|device_admin" --include="*.xml"
```

- [ ] No modification of system settings without explicit user action
- [ ] No DeviceAdminReceiver declared (unless core functionality requires it)
- [ ] No WiFi/Bluetooth state changes
- [ ] No volume/brightness manipulation

### 12.2 Accessibility Service Abuse

Accessibility services are heavily scrutinized. Using them for non-accessibility purposes is a **BLOCKER**.

#### Policy Update (October 30, 2025)

Google's updated policy explicitly states:

> "Any use of this API that enables an app to autonomously initiate, plan, and execute actions is prohibited."

**Prohibited autonomous behaviors**:
- Automatically modifying device settings or system preferences
- Bypassing Android privacy controls or permission dialogs
- Performing UI actions (clicks, scrolls, gestures) without real-time user awareness
- Automated form filling, screenshot capture, or button clicks via Accessibility API
- Executing UI operations in a deceptive manner (e.g., hidden overlay clicks)

**Special warning for financial apps**: The following patterns are **explicitly prohibited** even when the Accessibility API is declared for a legitimate accessibility purpose:
- Automated identity verification flows (auto-filling KYC forms)
- Automated form submission on behalf of the user
- Reading screen content from other apps (e.g., reading OTPs from SMS app, scraping bank balances)

**Code audit — autonomous action detection**:
```bash
# Check for autonomous action APIs (PROHIBITED since Oct 2025):
grep -rn "performAction\|performGlobalAction\|dispatchGesture" --include="*.kt"
grep -rn "AccessibilityNodeInfo.*ACTION_" --include="*.kt"

# Check for gesture injection:
grep -rn "GestureDescription\|StrokeDescription" --include="*.kt"

# Check for window content reading across apps:
grep -rn "getRootInActiveWindow\|getWindows" --include="*.kt"
```

**Code audit — standard accessibility checks**:
```bash
# Check for accessibility service declaration:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt"
grep -rn "accessibilityservice" --include="*.xml" app/src/main/

# Check for accessibility API usage:
grep -rn "AccessibilityEvent\|AccessibilityNodeInfo\|performAction" --include="*.kt"
```

- [ ] No AccessibilityService unless core functionality requires it
- [ ] No autonomous action initiation, planning, or execution via Accessibility API (Oct 2025 update)
- [ ] No `performAction` / `performGlobalAction` / `dispatchGesture` for non-user-initiated actions
- [ ] No reading screen content from other apps via `getRootInActiveWindow` / `getWindows`
- [ ] No automated form filling or UI interaction on behalf of the user
- [ ] No using accessibility APIs for automated UI interaction
- [ ] No using accessibility to scrape content from other apps
- [ ] If AccessibilityService is used: Permissions Declaration Form submitted with video demo

### 12.3 App Interference

Apps must not interfere with other apps or the operating system.

**Code audit**:
```bash
# Check for overlay permissions/usage:
grep -rn "SYSTEM_ALERT_WINDOW\|TYPE_APPLICATION_OVERLAY\|TYPE_SYSTEM_ALERT" --include="*.kt" --include="*.xml"

# Check for task/process manipulation:
grep -rn "ActivityManager.*killBackgroundProcesses\|forceStopPackage" --include="*.kt"

# Check for preventing uninstallation:
grep -rn "ACTION_UNINSTALL\|DELETE_PACKAGES\|PREVENT_UNINSTALL" --include="*.kt" --include="*.xml"
```

- [ ] No SYSTEM_ALERT_WINDOW for non-essential overlay functionality
- [ ] No killing other apps' background processes
- [ ] No mechanism to prevent or complicate app uninstallation

### 12.4 Network Abuse

**Code audit**:
```bash
# Check for proxy/VPN functionality:
grep -rn "VpnService\|BIND_VPN_SERVICE" --include="*.kt" --include="*.xml"

# Check for excessive network requests:
grep -rn "PeriodicWorkRequest\|repeatInterval\|setInitialDelay" --include="*.kt"
```

- [ ] No VPN/proxy functionality unless core to app purpose (see [VpnService policy](https://support.google.com/googleplay/android-developer/answer/12564964) for permitted use cases)
- [ ] No excessive background network polling
- [ ] No mining cryptocurrency in background

### 12.5 FLAG_SECURE Compliance

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9888379#flag-secure)): `FLAG_SECURE` is a display flag declared in an app's code to indicate that its UI contains sensitive data intended to be limited to a secure surface. For security and privacy purposes, all apps distributed on Google Play are required to respect the `FLAG_SECURE` declaration of other apps. Apps must not facilitate or create workarounds to bypass the `FLAG_SECURE` settings in other apps.

**Exemption**: Apps that qualify as an [Accessibility Tool](https://support.google.com/googleplay/android-developer/answer/10964491) are exempt, as long as they do not transmit, save, or cache `FLAG_SECURE` protected content for access outside of the user's device.

**Financial app relevance**: Financial apps commonly encounter `FLAG_SECURE` when integrating with banking SDKs, payment flows, or secure document viewers.

**Code audit**:
```bash
# Check for screen capture APIs that may violate FLAG_SECURE:
grep -rn "MediaProjection\|createScreenCapture\|PixelCopy" --include="*.kt" --include="*.java"

# Check for screenshot prevention bypass attempts:
grep -rn "FLAG_SECURE.*clear\|clearFlags.*FLAG_SECURE" --include="*.kt" --include="*.java"

# Check for screen recording functionality:
grep -rn "MediaRecorder.*setVideoSource\|SURFACE\|createVirtualDisplay" --include="*.kt" --include="*.java"
```

- [ ] App respects `FLAG_SECURE` on all windows (no screen capture of secure content)
- [ ] No `MediaProjection` usage unless core screen-sharing functionality
- [ ] No attempt to clear or bypass `FLAG_SECURE` on other apps' windows
- [ ] If app sets `FLAG_SECURE` on its own windows: verify it is applied consistently on sensitive screens (login, payment, KYC)

### 12.6 Device Abuse Checklist

- [ ] No device settings modification
- [ ] No accessibility service abuse
- [ ] No app interference
- [ ] No network abuse
- [ ] No preventing uninstallation
- [ ] App respects FLAG_SECURE set by other apps
- [ ] No root detection that blocks entire app (detecting root for security and warning user is acceptable; blocking app entirely may be flagged)
