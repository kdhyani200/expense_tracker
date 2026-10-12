import 'package:hive/hive.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 0)
class WalletModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double balance;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    this.imagePath,
    required this.createdAt,
  });
}
