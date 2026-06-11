import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation d'AdMob
  final initFuture = MobileAds.instance.initialize();
  
  // Initialisation du service Premium simulé
  final prefs = await SharedPreferences.getInstance();
  final premiumService = PremiumService(prefs);

  runApp(FrigoRecettesApp(premiumService: premiumService));
}

class FrigoRecettesApp extends StatelessWidget {
  final PremiumService premiumService;

  const FrigoRecettesApp({super.key, required this.premiumService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrigoRecettes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.orangeAccent,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(premiumService: premiumService),
    );
  }
}
