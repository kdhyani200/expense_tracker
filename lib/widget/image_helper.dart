import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<String?> pickAndSaveImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final appDir = await getApplicationDocumentsDirectory();

    final fileName = basename(image.path);

    final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

    return savedImage.path;
  }
}
