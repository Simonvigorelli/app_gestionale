import 'package:shared_preferences/shared_preferences.dart';

class TrialService {
  static const _firstLaunchKey = 'firstLaunchDate';

  /// Salva la data di primo avvio se non già presente
  static Future<void> initializeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstLaunchKey)) {
      await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
    }
  }

  static Future<String> getTrialExpirationDate() async {
  final prefs = await SharedPreferences.getInstance();
  final dateStr = prefs.getString(_firstLaunchKey);
  if (dateStr == null) return "data sconosciuta";
  final start = DateTime.tryParse(dateStr);
  if (start == null) return "data sconosciuta";
  final end = start.add(const Duration(days: 7));
  return "${end.day}/${end.month}/${end.year}";
}

  /// Restituisce `true` se il periodo di prova è ancora valido
  static Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_firstLaunchKey);
    if (dateStr == null) return true;
    final firstLaunch = DateTime.tryParse(dateStr);
    if (firstLaunch == null) return true;
    final now = DateTime.now();
    return now.difference(firstLaunch).inDays < 7;
  }
}
