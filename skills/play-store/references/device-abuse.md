# Device and Network Abuse

## Table of Contents
- [12.1 Device Settings Modification](#121-device-settings-modification)
- [12.2 Accessibility Service Abuse](#122-accessibility-service-abuse)
- [12.3 App Interference](#123-app-interference)
- [12.4 Network Abuse](#124-network-abuse)
- [12.5 Device Abuse Checklist](#125-device-abuse-checklist)

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

**Code audit**:
```bash
# Check for accessibility service declaration:
grep -rn "AccessibilityService\|BIND_ACCESSIBILITY_SERVICE" --include="*.xml" --include="*.kt"
grep -rn "accessibilityservice" --include="*.xml" app/src/main/

# Check for accessibility API usage:
grep -rn "AccessibilityEvent\|AccessibilityNodeInfo\|performAction" --include="*.kt"
```

- [ ] No AccessibilityService unless core functionality requires it
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

- [ ] No VPN/proxy functionality unless core to app purpose
- [ ] No excessive background network polling
- [ ] No mining cryptocurrency in background

### 12.5 Device Abuse Checklist

- [ ] No device settings modification
- [ ] No accessibility service abuse
- [ ] No app interference
- [ ] No network abuse
- [ ] No preventing uninstallation
- [ ] No root detection that blocks entire app (detecting root for security and warning user is acceptable; blocking app entirely may be flagged)
