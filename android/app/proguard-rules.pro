# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ML Kit Text Recognition
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**

# Drift / SQLite3
-keep class com.betterment.sqlite3.** { *; }
-keep class io.simonbinder.sqlite3.** { *; }
-dontwarn io.simonbinder.sqlite3.**
