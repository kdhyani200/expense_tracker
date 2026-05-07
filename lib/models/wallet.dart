import 'dart:io';

class Wallet {
  final String name;
  final String amount;
  final File? image;

  Wallet({required this.name, required this.amount, this.image});
}
