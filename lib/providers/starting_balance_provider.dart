import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartingBalanceProvider extends ChangeNotifier {
  static const _kSavedKey = 'initial_balance_saved';
  static const _kCashKey = 'starting_cash';
  static const _kBankKey = 'starting_bank';

  bool _loaded = false;
  bool _saved = false;
  double _cash = 0.0;
  double _bank = 0.0;

  StartingBalanceProvider() {
    _load();
  }

  bool get loaded => _loaded;
  bool get saved => _saved;
  double get cash => _cash;
  double get bank => _bank;
  double get total => _cash + _bank;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _saved = prefs.getBool(_kSavedKey) ?? false;
    _cash = prefs.getDouble(_kCashKey) ?? 0.0;
    _bank = prefs.getDouble(_kBankKey) ?? 0.0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setBalances({required double cash, required double bank}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSavedKey, true);
    await prefs.setDouble(_kCashKey, cash);
    await prefs.setDouble(_kBankKey, bank);
    _cash = cash;
    _bank = bank;
    _saved = true;
    notifyListeners();
  }

  Future<void> skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSavedKey, true);
    _saved = true;
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSavedKey);
    await prefs.remove(_kCashKey);
    await prefs.remove(_kBankKey);
    _saved = false;
    _cash = 0.0;
    _bank = 0.0;
    notifyListeners();
  }
}
