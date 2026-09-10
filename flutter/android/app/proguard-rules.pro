# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.internal.** { *; }
-keep class io.flutter.provider.** { *; }
-dontwarn io.flutter.embedding.**

# Keep models & annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
