import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

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
