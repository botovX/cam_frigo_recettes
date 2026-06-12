import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ApiService {
  // Mets TA clé API ici
  static const String _apiKey = "AIzaSy...la_suite_de_ta_clé_copiée...Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    final client = HttpClient();
    try {
      // URL directe vers la route v1beta officielle de Google
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      // Encodage de l'image
      final base64Image = base64Encode(imageBytes);

      // Structure de données JSON demandée par Gemini
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

      // Ouverture de la connexion réseau native
      final request = await client.postUrl(uri);
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(jsonEncode(corpsRequete)));

      // Récupération de la réponse
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final texteGenere = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return texteGenere ?? "L'IA a renvoyé une réponse vide.";
      } else {
        return "Erreur du serveur Google (Code ${response.statusCode}): $responseBody";
      }
    } catch (e) {
      return "Exception: Erreur lors de la communication avec l'IA : $e";
    } finally {
      client.close(); // Fermeture propre du client
    }
  }
}
