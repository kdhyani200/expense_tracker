// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final _plugin = FlutterLocalNotificationsPlugin();
//   static const _channelId = 'trackkar_reminder';
//   static const _channelName = 'Daily Reminder';
//   static const _notifId = 1;
//   static const _prefBox = 'preferences';
//
//   static Future<void> init() async {
//     // Initialise timezone database
//     tz.initializeTimeZones();
//
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const ios = DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );
//     await _plugin.initialize(
//       const InitializationSettings(android: android, iOS: ios),
//     );
//
//     // Create notification channel (Android 8+)
//     const channel = AndroidNotificationChannel(
//       _channelId,
//       _channelName,
//       description: 'Reminds you to log transactions if unused for 8 hours',
//       importance: Importance.defaultImportance,
//     );
//     await _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//   }
//
//   /// Call every time the app comes to foreground.
//   static Future<void> onAppOpen() async {
//     final box = Hive.box(_prefBox);
//     await box.put('lastAppOpen', DateTime.now().millisecondsSinceEpoch);
//
//     final enabled =
//         box.get('notificationsEnabled', defaultValue: false) as bool;
//     if (enabled) {
//       await scheduleReminder();
//     } else {
//       await cancelReminder();
//     }
//   }
//
//   /// Schedules a local notification 8 hours from now.
//   /// Uses [zonedSchedule] which is the correct API in v9+.
//   static Future<void> scheduleReminder() async {
//     await cancelReminder();
//
//     final scheduledTime = tz.TZDateTime.now(
//       tz.local,
//     ).add(const Duration(minutes: 1));
//
//     const androidDetails = AndroidNotificationDetails(
//       _channelId,
//       _channelName,
//       channelDescription: 'Reminds you to log transactions',
//       importance: Importance.defaultImportance,
//       priority: Priority.defaultPriority,
//     );
//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );
//
//     await _plugin.zonedSchedule(
//       _notifId,
//       "👋 Don't forget to track!",
//       "You haven't opened TrackKar in a while. Log your transactions now.",
//       scheduledTime,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   static Future<void> cancelReminder() async {
//     await _plugin.cancel(_notifId);
//   }
//
//   /// Called when the toggle changes in preferences.
//   static Future<void> setEnabled(bool enabled) async {
//     if (enabled) {
//       await scheduleReminder();
//     } else {
//       await cancelReminder();
//     }
//   }
// }
