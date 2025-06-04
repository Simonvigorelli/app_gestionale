import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const _keyIsPremium = 'isPremium';

  /// Salva lo stato premium (true se l'utente ha acquistato o sottoscritto)
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, value);
  }

  /// Ritorna true se l’utente è premium
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }
}
