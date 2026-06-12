import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  // Mets TA clé API ici à la place de celle-ci
  static const String _apiKey = "AIzaSy...la_suite_de_ta_clé_copiée...Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    try {
      // Configuration magique : on force l'API à passer par v1beta pour accepter Gemini 1.5
      final config = ApiClientConfig(apiVersion: 'v1beta');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        clientConfig: config, // On injecte la configuration ici
      );

      final prompt = TextPart(
        "Regarde cette photo de mon frigo/cuisine. Écris une liste de recettes claires et réalisables uniquement avec les ingrédients visibles ou des basiques de placard (sel, huile, poivre). Donne des instructions étape par étape.",
      );

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text != null) {
        return response.text!;
      } else {
        return "L'IA n'a pas pu générer de texte pour cette image.";
      }
    } catch (e) {
      return "Exception: Erreur lors de la génération : $e";
    }
  }
}
