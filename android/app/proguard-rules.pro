# Mantém metadados usados em runtime pelo Flutter e plugins.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Flutter Engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Cloud Firestore (mantém modelos serializados via reflexão)
-keep class * implements com.google.firebase.firestore.PropertyName { *; }
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <methods>;
    @com.google.firebase.firestore.PropertyName <fields>;
}

# AndroidX Biometric / local_auth
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# flutter_secure_storage
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Não logar nada da linha do tempo do app em release.
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
