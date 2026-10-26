# ==============================================================================
# AUPL Sales Team App - ProGuard / R8 Hardening Rules (ANDROID.md)
# ==============================================================================

# Flutter & Dart Core Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase Services & Annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Integrity API
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.integrity.**

# Data Models Serialization (GSON / JSON mapping)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# SQLite & SQLCipher Encryption bindings
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }
-dontwarn net.sqlcipher.**

# Bluetooth ESC/POS Print Drivers
-keep class android.bluetooth.** { *; }

# Release Hardening: Strip verbose logging
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}
