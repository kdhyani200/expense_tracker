import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String walletId;

  @HiveField(2)
  String title;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String category;

  @HiveField(5)
  TransactionType type;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String note;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    required this.note,
  });
}
