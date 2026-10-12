import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'models/wallet_model.dart';
import 'providers/preferences_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> _initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(WalletModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(2))
    Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(1))
    Hive.registerAdapter(TransactionTypeAdapter());
  if (!Hive.isAdapterRegistered(4))
    Hive.registerAdapter(CategoryModelAdapter());
  if (!Hive.isBoxOpen('wallets')) await Hive.openBox<WalletModel>('wallets');
  if (!Hive.isBoxOpen('user')) await Hive.openBox<UserModel>('user');
  if (!Hive.isBoxOpen('transactions'))
    await Hive.openBox<TransactionModel>('transactions');
  if (!Hive.isBoxOpen('categories'))
    await Hive.openBox<CategoryModel>('categories');
  if (!Hive.isBoxOpen('preferences')) await Hive.openBox('preferences');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  // Lock to portrait on phones; allow all orientations on tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await _initHive();
  _runApp();
}

void _runApp() {
  runApp(const ProviderScope(child: _MyApp()));
}

void resetAndRestart() => _runApp();

class _MyApp extends ConsumerWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final isProfileSet =
        Hive.box<UserModel>('user').get('current_user') != null;

    return MaterialApp(
      title: 'Track Kar',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      home: isProfileSet ? const MainScreen() : const OnBoarding(),
    );
  }

  ThemeData _lightTheme() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,
    canvasColor: const Color.fromARGB(255, 248, 247, 247),
    cardColor: const Color(0xFF00885d),
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
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    useMaterial3: false,
  );

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0f172a),
    primaryColor: Colors.white,
    canvasColor: const Color(0xFF1a222e),
    cardColor: const Color(0xFF00885d),
    dividerColor: Colors.grey.shade800,
    shadowColor: Colors.black.withValues(alpha: 0.25),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.grey,
      surface: Color(0xFF1a222e),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0f172a),
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    useMaterial3: false,
  );
}
