# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# CRITICAL: Add these keepattributes directives FIRST
-keepattributes Exceptions, InnerClasses, Signature, Deprecated, 
                SourceFile, LineNumberTable, 
                *Annotation*, EnclosingMethod

# AndroidX
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Platform Channels
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

# Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# JSON/GSON annotations
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation { *; }

# Google Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep View setters/getters
-keepclassmembers public class * extends android.view.View {
    void set*(***);
    *** get*();
}

# Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# For method reflection
-keepclassmembers class **.R$* {
    public static <fields>;
}

# If using Kotlin
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keep class kotlin.** { *; }
-dontwarn kotlin.**
