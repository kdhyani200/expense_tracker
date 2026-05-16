import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Flutter IconData.codePoint — stored so we can reconstruct the icon.
  /// -1 means a gallery image is used instead.
  @HiveField(2)
  int iconCodePoint;

  /// Hex color int (e.g. 0xFF4CAF50).
  @HiveField(3)
  int colorValue;

  /// 'income' or 'expense'
  @HiveField(4)
  String type;

  /// Absolute path to a gallery-picked image, or null if using an icon.
  @HiveField(5)
  String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
    this.imagePath,
  });
}
