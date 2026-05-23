# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keep class ** extends com.hiveadb.hive.HiveObject { *; }

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# open_filex
-keep class com.crazecoder.openfile.** { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Keep model classes (Hive adapters)
-keep class com.example.expense_tracker.** { *; }
-keepclassmembers class ** {
    @com.hivedb.hive.annotations.HiveField *;
}

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
