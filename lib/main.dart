import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation d'AdMob
  await MobileAds.instance.initialize();
  
  // Initialisation du service Premium
  final prefs = await SharedPreferences.getInstance();
  final premiumService = PremiumService(prefs);

  runApp(FrigoRecettesApp(premiumService: premiumService));
}

class FrigoRecettesApp extends StatelessWidget {
  final PremiumService premiumService;

  const FrigoRecettesApp({Key? key, required this.premiumService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrigoRecettes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(premiumService: premiumService),
    );
  }
}
