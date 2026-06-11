import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  // ⚠️ Remplacez par votre propre clé API Gemini
  static const String _apiKey = "VOTRE_CLE_API_GEMINI";

  static Future<Map<String, dynamic>> genererRecettes(Uint8List imageBytes) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      const prompt = '''
      Analyse cette image de l'intérieur d'un frigo. Identifie les ingrédients présents et propose une liste de recettes équilibrées (sans restriction calorique particulière) réalisables avec ces ingrédients (tu peux ajouter des ingrédients de base comme du sel, poivre, huile, eau).
      
      Tu DOIS répondre EXCLUSIVEMENT sous la forme d'un objet JSON respectant strictement cette structure :
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
      génère un maximum de recettes possibles (au moins 4 ou 5 si possible).
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

      // Décodage du JSON renvoyé par l'IA
      return jsonDecode(response.text!) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Erreur lors de la génération : $e");
    }
  }
}
