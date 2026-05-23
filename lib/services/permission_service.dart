import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+
      if (await Permission.photos.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Android 11+
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      // Android 10 and below
      final status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    }

    return true;
  }
}
