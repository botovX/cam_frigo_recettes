import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'premium_service.dart';

class HomeScreen extends StatefulWidget {
  final PremiumService premiumService;
  const HomeScreen({Key? key, required this.premiumService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<dynamic> _ingredients = [];
  List<dynamic> _recettes = [];

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _loadInterstitialAd();
    }
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.camera);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyserFrigo() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final data = await ApiService.genererRecettes(bytes);

      setState(() {
        _ingredients = data['ingredients_detectes'] ?? [];
        _recettes = data['recettes'] ?? [];
        _isLoading = false;
      });

      _showInterstitialAd();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _debloquerPremium() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await widget.premiumService.purchasePremium();
    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Félicitations ! Version Premium activée 🎉')),
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPremium = widget.premiumService.isPremium();
    int recettesAfficheesCount = isPremium ? _recettes.length : (_recettes.length > 2 ? 2 : _recettes.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FrigoRecettes 🍳'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
        actions: [
          if (!isPremium)
            TextButton.icon(
              onPressed: _debloquerPremium,
              icon: const Icon(Icons.star, color: Colors.amber),
              label: const Text('Premium', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: Text('PRO ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.teal),
                                SizedBox(height: 8),
                                Text('Prendre une photo du frigo'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _imageFile != null && !_isLoading ? _analyserFrigo : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Générer mes recettes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_errorMessage != null)
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  if (_ingredients.isNotEmpty && !_isLoading) ...[
                    const Text('Ingrédients détectés :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _ingredients.map((ing) => Chip(label: Text(ing.toString()))).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_recettes.isNotEmpty && !_isLoading) ...[
                    const Text('Vos Recettes :', style: TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recettesAfficheesCount,
                      itemBuilder: (context, index) {
                        final recette = _recettes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ExpansionTile(
                            title: Text(recette['titre'] ?? 'Recette sans nom', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('⏱️ ${recette['temps'] ?? 'N/A'}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Préparation :', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    ...(recette['etapes'] as List<dynamic>).map((etape) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text('• $etape'),
                                        )),
                                    if (recette['astuce'] != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                                        child: Text('💡 Astuce : ${recette['astuce']}', style: TextStyle(color: Colors.orange.shade900, fontStyle: FontStyle.italic)),
                                      ),
                                    ]
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    if (!isPremium && _recettes.length > 2)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Il reste ${_recettes.length - 2} autres recettes gourmandes à découvrir !',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _debloquerPremium,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                              child: const Text('Débloquer toutes les recettes (Premium)'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (_isBannerLoaded && _bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
