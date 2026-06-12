import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  // Remplace bien par TA clé API complète à l'intérieur des guillemets
  static const String _apiKey = "AIzaSy...la_suite_de_ta_clé_copiée...Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = TextPart(
        "Regarde cette photo de mon frigo/cuisine. Écris une liste de recettes claires et réalisables uniquement avec les ingrédients visibles ou des basiques de placard (sel, huile, poivre). Donne des instructions étape par étape.",
      );

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text ?? "L'IA a renvoyé une réponse vide.";
    } catch (e) {
      return "Exception: Erreur lors de la génération : $e";
    }
  }
}
