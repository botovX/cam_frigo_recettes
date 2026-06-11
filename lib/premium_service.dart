import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  final SharedPreferences _prefs;
  static const String _premiumKey = "is_premium_user";

  PremiumService(this._prefs);

  // Vérifie si l'utilisateur est premium
  bool isPremium() {
    return _prefs.getBool(_premiumKey) ?? false;
  }

  // Simule l'achat premium
  Future<bool> purchasePremium() async {
    // On simule un délai de traitement réseau/bancaire
    await Future.delayed(const Duration(seconds: 1));
    return await _prefs.setBool(_premiumKey, true);
  }

  // Optionnel : pour réinitialiser l'achat lors des tests
  Future<void> resetPremium() async {
    await _prefs.setBool(_premiumKey, false);
  }
}
