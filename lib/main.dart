import 'dart:typed_data';
import 'package:flutter/material';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frigo Recettes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterialDesign: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _resultat = "Prenez une photo de votre frigo pour commencer !";
  bool _enChargement = false;
  final Uint8List _imageSimulee = Uint8List(0); 

  Future<void> _envoyerImage() async {
    setState(() {
      _enChargement = true;
      _resultat = "Analyse du frigo en cours...";
    });

    final reponseIA = await ApiService.genererRecettes(_imageSimulee);

    setState(() {
      _resultat = reponseIA;
      _enChargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FrigoRecettes 🍳"),
        centerTitle: true,
        backgroundColor: const Color(0xFFB2DFDB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _enChargement ? null : _envoyerImage,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Générer mes recettes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            _enChargement
                ? const CircularProgressIndicator()
                : Text(
                    _resultat,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
          ],
        ),
      ),
    );
  }
}
