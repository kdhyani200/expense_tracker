import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppPreferences {
  final ThemeMode themeMode;
  final String currencySymbol;
  final String currencyCode;
  final int decimalPlaces;

  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.currencySymbol = '₹',
    this.currencyCode = 'INR',
    this.decimalPlaces = 2,
  });

  AppPreferences copyWith({
    ThemeMode? themeMode,
    String? currencySymbol,
    String? currencyCode,
    int? decimalPlaces,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    );
  }
}

const _boxName = 'preferences';

class PreferencesNotifier extends Notifier<AppPreferences> {
  late Box _box;

  @override
  AppPreferences build() {
    _box = Hive.box(_boxName);
    return _load();
  }

  AppPreferences _load() {
    final modeStr = _box.get('themeMode', defaultValue: 'system') as String;
    final mode = modeStr == 'dark'
        ? ThemeMode.dark
        : modeStr == 'light'
            ? ThemeMode.light
            : ThemeMode.system;

    return AppPreferences(
      themeMode: mode,
      currencySymbol: _box.get('currencySymbol', defaultValue: '₹') as String,
      currencyCode: _box.get('currencyCode', defaultValue: 'INR') as String,
      decimalPlaces: _box.get('decimalPlaces', defaultValue: 2) as int,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final str = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await _box.put('themeMode', str);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setCurrency(String symbol, String code) async {
    await _box.put('currencySymbol', symbol);
    await _box.put('currencyCode', code);
    state = state.copyWith(currencySymbol: symbol, currencyCode: code);
  }

  Future<void> setDecimalPlaces(int places) async {
    await _box.put('decimalPlaces', places);
    state = state.copyWith(decimalPlaces: places);
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, AppPreferences>(
        PreferencesNotifier.new);

// ── Currency list ─────────────────────────────────────────────────────────────

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  const CurrencyInfo(this.code, this.symbol, this.name, this.flag);
}

const List<CurrencyInfo> kCurrencies = [
  CurrencyInfo('INR', '₹', 'Indian Rupee', '🇮🇳'),
  CurrencyInfo('USD', '\$', 'US Dollar', '🇺🇸'),
  CurrencyInfo('EUR', '€', 'Euro', '🇪🇺'),
  CurrencyInfo('GBP', '£', 'British Pound', '🇬🇧'),
  CurrencyInfo('JPY', '¥', 'Japanese Yen', '🇯🇵'),
  CurrencyInfo('CNY', '¥', 'Chinese Yuan', '🇨🇳'),
  CurrencyInfo('AUD', 'A\$', 'Australian Dollar', '🇦🇺'),
  CurrencyInfo('CAD', 'C\$', 'Canadian Dollar', '🇨🇦'),
  CurrencyInfo('CHF', 'Fr', 'Swiss Franc', '🇨🇭'),
  CurrencyInfo('SGD', 'S\$', 'Singapore Dollar', '🇸🇬'),
  CurrencyInfo('AED', 'د.إ', 'UAE Dirham', '🇦🇪'),
  CurrencyInfo('SAR', '﷼', 'Saudi Riyal', '🇸🇦'),
  CurrencyInfo('MYR', 'RM', 'Malaysian Ringgit', '🇲🇾'),
  CurrencyInfo('IDR', 'Rp', 'Indonesian Rupiah', '🇮🇩'),
  CurrencyInfo('PHP', '₱', 'Philippine Peso', '🇵🇭'),
  CurrencyInfo('THB', '฿', 'Thai Baht', '🇹🇭'),
  CurrencyInfo('KRW', '₩', 'South Korean Won', '🇰🇷'),
  CurrencyInfo('BRL', 'R\$', 'Brazilian Real', '🇧🇷'),
  CurrencyInfo('MXN', 'Mex\$', 'Mexican Peso', '🇲🇽'),
  CurrencyInfo('ZAR', 'R', 'South African Rand', '🇿🇦'),
  CurrencyInfo('NGN', '₦', 'Nigerian Naira', '🇳🇬'),
  CurrencyInfo('PKR', '₨', 'Pakistani Rupee', '🇵🇰'),
  CurrencyInfo('BDT', '৳', 'Bangladeshi Taka', '🇧🇩'),
  CurrencyInfo('EGP', 'E£', 'Egyptian Pound', '🇪🇬'),
  CurrencyInfo('TRY', '₺', 'Turkish Lira', '🇹🇷'),
  CurrencyInfo('RUB', '₽', 'Russian Ruble', '🇷🇺'),
  CurrencyInfo('SEK', 'kr', 'Swedish Krona', '🇸🇪'),
  CurrencyInfo('NOK', 'kr', 'Norwegian Krone', '🇳🇴'),
  CurrencyInfo('DKK', 'kr', 'Danish Krone', '🇩🇰'),
  CurrencyInfo('NZD', 'NZ\$', 'New Zealand Dollar', '🇳🇿'),
];
