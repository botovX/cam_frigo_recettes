import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// --- SECTION SERVICE APPAREIL ET IA ---
class ApiService {
  // COPIE TA VRAIE CLÉ ENTIÈRE ENTRE LES GUILLEMETS ICI :
  static const String _apiKey = "AQ.Ab8RN6IZEEdi8hnMpxYTE4zEsn8VXf8pdpcpYIP-7DlWf1Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      final base64Image = base64Encode(imageBytes);

      final corpsRequete = {
        "contents": [
          {
            "parts": [
              {
                "text": "Regarde cette photo de mon frigo/cuisine. Écris une liste de recettes claires et réalisables uniquement avec les ingrédients visibles ou des basiques de placard (sel, huile, poivre). Donne des instructions étape par étape."
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpsRequete),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final texteGenere = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return texteGenere ?? "L'IA a renvoyé une réponse vide.";
      } else {
        return "Erreur Gemini (Code ${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Exception: Erreur de communication : $e";
    }
  }
}

// --- SECTION INTERFACE GRAPHIQUE ---
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
