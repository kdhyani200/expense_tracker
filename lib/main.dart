import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

import 'models/category_model.dart';
import 'models/wallet_model.dart';
import 'models/user_model.dart';
import 'models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // REGISTER ADAPTERS
  Hive.registerAdapter(WalletModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // OPEN BOXES
  await Hive.openBox<WalletModel>('wallets');
  await Hive.openBox<UserModel>('user');
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');

  // CHECK USER EXISTS
  final userBox = Hive.box<UserModel>('user');
  final bool isProfileSet = userBox.isNotEmpty;

  runApp(ProviderScope(child: MyApp(isProfileSet: isProfileSet)));
}

class MyApp extends StatelessWidget {
  final bool isProfileSet;
  const MyApp({super.key, required this.isProfileSet});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Kar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00885d)),
        useMaterial3: true,
      ),
      home: isProfileSet ? const MainScreen() : const OnBoarding(),
    );
  }
}
