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

# Plugins and native integration
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**
-keep class net.nfet.flutter.printing.** { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
