# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter deferred components — suppress R8 warnings about Play Core split-install
# classes that Flutter's engine references but this app never uses.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Hive
-keep class com.hiveadb.** { *; }
-keepclassmembers class ** {
    @com.hivedb.hive.annotations.HiveField *;
}

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# open_filex
-keep class com.crazecoder.openfile.** { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Keep generated Hive adapters
-keep class **.*.* extends com.hiveadb.hive.HiveObject { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
