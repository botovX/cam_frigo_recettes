import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  // Mets TA clé API ici
  static const String _apiKey = "AIzaSy...la_suite_de_ta_clé_copiée...Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    try {
      // Nous ciblons directement l'URL officielle v1beta qui accepte gemini-1.5-flash
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      // Préparation des données de l'image en Base64
      final base64Image = base64Encode(imageBytes);

      // Construction de la requête exacte attendue par Google
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

      // Envoi de la requête au serveur Google
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpsRequete),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Extraction du texte de la réponse de l'IA
        final texteGenere = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return texteGenere ?? "L'IA a renvoyé une réponse vide.";
      } else {
        return "Erreur du serveur Google (Code ${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Exception: Erreur lors de la communication avec l'IA : $e";
    }
  }
}
