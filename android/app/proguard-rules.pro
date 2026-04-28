-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn com.google.j2objc.annotations.ReflectionSupport

# google_sign_in v7 — Flutter plugin bridge
-keep class io.flutter.plugins.googlesignin.** { *; }

# Google Play Services Auth (needed for token exchange)
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# AndroidX Credential Manager — used by google_sign_in v7 for session persistence
-keep class androidx.credentials.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }
