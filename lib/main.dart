import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

import 'models/category_model.dart';
import 'providers/preferences_provider.dart';
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
  await Hive.openBox('preferences');

  // CHECK USER EXISTS
  final userBox = Hive.box<UserModel>('user');
  final bool isProfileSet = userBox.isNotEmpty;

  runApp(ProviderScope(child: MyApp(isProfileSet: isProfileSet)));
}

class MyApp extends ConsumerWidget {
  final bool isProfileSet;
  const MyApp({super.key, required this.isProfileSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    return MaterialApp(
      title: 'Track Kar',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        canvasColor: Colors.white,
        cardColor: Color(0xFF00885d),
        dividerColor: Colors.grey.shade100,
        shadowColor: Colors.grey.shade200,

        colorScheme: ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.grey.shade800,
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0f172a),
        primaryColor: Colors.white,
        canvasColor: Color(0xFF1a222e),
        cardColor: Color(0xFF00885d),
        dividerColor: Colors.grey.shade800,
        shadowColor: Colors.black.withValues(alpha: 0.25),

        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Colors.black,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0f172a),
          elevation: 0,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      // theme: ThemeData(
      //   brightness: Brightness.light,
      //   scaffoldBackgroundColor: Colors.white,
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00885d)),
      //   useMaterial3: true,
      // ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF00885d),
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      home: isProfileSet ? const MainScreen() : const OnBoarding(),
    );
  }
}
