import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    // Non-Android platforms
    if (!Platform.isAndroid) {
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Android 13+ (API 33+)
    // Storage permission is NOT required
    // File picker & save dialog handle access automatically
    if (sdkInt >= 33) {
      return true;
    }

    // Android 6 - Android 12
    final PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
