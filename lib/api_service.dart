import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  // ⚠️ Mettez votre clé API Gemini ici
  static const String _apiKey = "AQ.Ab8RN6IZEEdi8hnMpxYTE4zEsn8VXf8pdpcpYIP-7DlWf1Jh5g";

  static Future<Map<String, dynamic>> genererRecettes(Uint8List imageBytes) async {
    try {
      // Utilisation du modèle flash compatible
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: _apiKey,
      );

      const prompt = '''
      Analyse cette image de l'intérieur d'un frigo. Identifie les ingrédients présents et propose une liste de recettes équilibrées (sans restriction calorique particulière) réalisables avec ces ingrédients (tu peux ajouter des ingrédients de base comme du sel, poivre, huile, eau).
      
      Tu DOIS répondre EXCLUSIVEMENT sous la forme d'un objet JSON valide respectant strictement cette structure, sans texte avant ni après, et sans les balises markdown ```json :
      {
        "ingredients_detectes": ["ingrédient 1", "ingrédient 2"],
        "recettes": [
          {
            "titre": "Nom de la recette",
            "temps": "30 min",
            "etapes": ["Étape 1", "Étape 2"],
            "astuce": "Une astuce de chef"
          }
        ]
      }
      Génère un maximum de recettes possibles (au moins 4 ou 5 si possible).
      ''';

      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart(prompt),
        ])
      ];

      final response = await model.generateContent(content);
      
      if (response.text == null) {
        throw Exception("L'API Gemini a renvoyé une réponse vide.");
      }

      // Nettoyage au cas où l'IA mettrait quand même des balises markdown
      String cleanText = response.text!.trim();
      if (cleanText.startsWith('```')) {
        cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '').trim();
      }

      return jsonDecode(cleanText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Erreur lors de la génération : $e");
    }
  }
}
