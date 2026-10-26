# AUPL Sales Team App — Android Platform Specification (ANDROID.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Target Platform:** Native Android (via Flutter Engine)  
**Document Version:** 1.0.0  

---

## 1. Android Build & SDK Specifications

| Configuration Parameter | Target Specification | Notes & Rationale |
|---|---|---|
| **Minimum SDK (`minSdkVersion`)** | `24` (Android 7.0 Nougat) | Covers 98%+ of enterprise Android smartphones in India. |
| **Target SDK (`targetSdkVersion`)** | `34` (Android 14) / `35` (Android 15) | Complies with Google Play Store 2026/2027 enforcement guidelines. |
| **Compile SDK (`compileSdkVersion`)** | `34` | Full access to modern Android platform APIs. |
| **Java Version** | Java 17 | Required by modern Gradle 8.x and Android Gradle Plugin 8.x. |
| **Kotlin Version** | `1.9.22`+ | Standard Flutter Android runtime. |
| **Build Artifact** | Android App Bundle (`.aab`) & Universal APK (`.apk`)| Enterprise distribution via MDM or Google Play Private Track. |

---

## 2. Hardware Geolocation & Anti-Mock Implementation

To satisfy **Rules 3 & 4 (GPS verification & mock location blocking)**:

### 2.1 Android Location Settings & Manifest Directives
```xml
<!-- High Accuracy GPS Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Foreground Service for Continuous Route Tracking (Optional) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

### 2.2 Anti-Mock GPS Logic in Kotlin / Dart
On Android 12+ (API 31+), `Location.isMock()` is the canonical API. On older versions, check `Location.isFromMockProvider()`:
```dart
Future<bool> verifyRealLocation(Position position) async {
  // Check if position was flagged by Android OS as mock/spoofed
  if (position.isMocked) {
    return false; // Spoof detected!
  }
  
  // Ensure GPS accuracy threshold is tight (<= 25 meters)
  if (position.accuracy > 25.0) {
    return false; // Accuracy too low, might be cell tower triangulation
  }

  return true;
}
```

---

## 3. Bluetooth Thermal & A4 Printing on Android

### 3.1 Portable Bluetooth Thermal Printer (ESC/POS)
Field representatives often carry portable 58mm or 80mm Bluetooth belt-printers to issue instant payment receipts.
* **Bluetooth Permissions:**
```xml
<!-- Android 12+ Bluetooth Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<!-- Legacy Bluetooth Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
```
* **Supported Protocols:** Standard ESC/POS commands (Raw byte streaming over RFCOMM socket).

### 3.2 A4 Document Printing via Android Print Manager
For formal A4 Party Ledgers, the app utilizes the native Android Print Spooler:
* Integrates with Android Print Services (Mopria, HP Print Service, Canon Print Service, or Wi-Fi Direct).
* Invoked via `Printing.layoutPdf()` in Flutter, presenting the standard Android system print preview dialog.

---

## 4. Battery Optimization & Power Management

Field sales apps can be killed by aggressive Android vendor battery savers (Xiaomi MIUI, Vivo FuntouchOS, Realme UI).
* **Mitigation:**
  * Implement an onboarding guidance dialog directing users to set the AUPL app battery usage to **"Unrestricted"**.
  * Use lightweight location polling only while the app is active and during check-in attempts rather than high-drain background location pinging.

---

## 5. Security & Keystore Encryption

* **Hardware Device ID:** Retrieved using Android `Settings.Secure.ANDROID_ID` combined with an AES key generated inside the **Android Keystore Provider** (`AndroidKeyStore`).
* **Offline Database Encryption:** SQLite database encrypted using `SQLCipher` (256-bit AES), with the key stored in the secure hardware-backed Android Keystore.
* **Network Security Configuration:** Strict HTTPS enforcement with cleartext traffic disabled in `AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="false"
    android:networkSecurityConfig="@xml/network_security_config" ...>
```

---

## 6. ProGuard / R8 Release Optimization

To minimize APK size and prevent reverse-engineering of corporate logic:

```proguard
# Flutter & Dart Core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }

# Firebase Services
-keepattributes *Annotation*
-keepattributes Signature
-keep class com.google.firebase.** { *; }

# Prevent Obfuscation of Data Models for Serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# SQLCipher / SQLite bindings
-keep class net.sqlcipher.** { *; }
```
