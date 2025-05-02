import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/routes.dart';
import '../models/apiResponse.dart';
import 'UserSessionService.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

class HomeService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer les séances du jour pour l'étudiant connecté
  Future<ApiResponse> getSeancesDuJour() async {
    try {
      dev.log("Début de récupération des séances du jour");
      
      // Récupérer les données de l'utilisateur connecté
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        dev.log("Erreur: Utilisateur non connecté");
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      // Récupérer l'ID de la classe de l'étudiant
      String? classeId;
      
      if (userData['data'] != null && 
          userData['data']['details'] != null && 
          userData['data']['details']['classeId'] != null) {
        classeId = userData['data']['details']['classeId'];
        dev.log("ClasseId récupéré: $classeId");
      }
      
      if (classeId == null) {
        dev.log("Erreur: Classe de l'étudiant non trouvée");
        return ApiResponse(
          success: false,
          message: 'Classe de l\'étudiant non trouvée',
        );
      }

      // Pour les tests, récupérer toutes les séances au lieu de filtrer par date
      dev.log("Appel API pour récupérer toutes les séances");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      dev.log("Réponse API reçue: ${response.statusCode}");
      dev.log("Données reçues: ${data.toString().substring(0, data.toString().length > 100 ? 100 : data.toString().length)}...");

      if (response.statusCode == 200 && data['success'] == true) {
        // Récupérer toutes les séances sans filtrage
        List<dynamic> allSeances = data['data'] ?? [];
        dev.log("Nombre total de séances récupérées: ${allSeances.length}");
        
        // Afficher les IDs de classe disponibles pour le débogage
        Set<String> classeIds = allSeances
            .where((s) => s['classeId'] != null)
            .map<String>((s) => s['classeId'].toString())
            .toSet();
        dev.log("IDs de classe disponibles dans les données: $classeIds");
        dev.log("ID de classe de l'étudiant connecté: $classeId");
        
        // Désactiver temporairement le filtrage par classeId
        List<Map<String, dynamic>> filteredSeances = [];
        for (var seance in allSeances) {
          // Convertir en Map<String, dynamic>
          filteredSeances.add(Map<String, dynamic>.from(seance));
          
          // Afficher les détails de chaque séance pour le débogage
          dev.log("Séance ajoutée - ID: ${seance['id']}, classeId: ${seance['classeId']}, jour: ${seance['jour']}");
        }
        
        dev.log("Nombre de séances après traitement: ${filteredSeances.length}");
        
        return ApiResponse(
          success: true,
          message: 'Séances récupérées avec succès',
          data: {
            'data': filteredSeances
          },
        );
      } else {
        dev.log("Erreur API: ${data['message'] ?? 'Erreur inconnue'}");
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des séances du jour',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les informations sur les cours
  Future<ApiResponse> getCoursByIds(List<String> coursIds) async {
    try {
      dev.log("Récupération des informations sur ${coursIds.length} cours");
      List<Map<String, dynamic>> cours = [];
      
      // Pour chaque ID de cours, faire une requête
      for (String coursId in coursIds) {
        final response = await http.get(
          Uri.parse('${ApiRoutes.baseURL}/cours/$coursId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200 && data['success'] == true && data['data'] != null) {
          cours.add(data['data']);
        }
      }

      dev.log("${cours.length} cours récupérés avec succès");
      return ApiResponse(
        success: true,
        message: 'Cours récupérés avec succès',
        data: cours,
      );
    } catch (e) {
      dev.log("Exception lors de la récupération des cours: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les informations sur les salles
  Future<ApiResponse> getSallesByIds(List<String> salleIds) async {
    try {
      dev.log("Récupération des informations sur ${salleIds.length} salles");
      List<Map<String, dynamic>> salles = [];
      
      // Pour chaque ID de salle, faire une requête
      for (String salleId in salleIds) {
        final response = await http.get(
          Uri.parse('${ApiRoutes.baseURL}/salles/$salleId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200 && data['success'] == true && data['data'] != null) {
          salles.add(data['data']);
        }
      }

      dev.log("${salles.length} salles récupérées avec succès");
      return ApiResponse(
        success: true,
        message: 'Salles récupérées avec succès',
        data: salles,
      );
    } catch (e) {
      dev.log("Exception lors de la récupération des salles: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les informations sur les enseignants
  Future<ApiResponse> getEnseignantsByIds(List<String> enseignantIds) async {
    try {
      dev.log("Récupération des informations sur ${enseignantIds.length} enseignants");
      List<Map<String, dynamic>> enseignants = [];
      
      // Pour chaque ID d'enseignant, faire une requête
      for (String enseignantId in enseignantIds) {
        final response = await http.get(
          Uri.parse('${ApiRoutes.baseURL}/enseignants/$enseignantId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200 && data['success'] == true && data['data'] != null) {
          enseignants.add(data['data']);
        }
      }

      dev.log("${enseignants.length} enseignants récupérés avec succès");
      return ApiResponse(
        success: true,
        message: 'Enseignants récupérés avec succès',
        data: enseignants,
      );
    } catch (e) {
      dev.log("Exception lors de la récupération des enseignants: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les séances du jour pour un enseignant spécifique
  Future<ApiResponse> getSeancesDuJourByEnseignant(String enseignantId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/enseignants/$enseignantId/seances/today'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Séances du jour récupérées avec succès',
          data: data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des séances du jour',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les séances d'un enseignant pour une date spécifique
  Future<ApiResponse> getSeancesByEnseignantAndDate(String enseignantId, String date) async {
    try {
      dev.log("Récupération des séances pour l'enseignant $enseignantId à la date $date");
      
      // Utiliser l'endpoint /seances/enseignant/{enseignantId} qui existe dans le contrôleur
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/enseignant/$enseignantId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      dev.log("Réponse API reçue: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Filtrer les séances pour ne garder que celles de la date spécifiée
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> allSeances = data['data'];
          List<Map<String, dynamic>> filteredSeances = [];
          
          // Convertir la date spécifiée en objet DateTime pour la comparaison
          DateTime targetDate = DateTime.parse(date);
          
          for (var seance in allSeances) {
            // Vérifier si la séance a une date de début et si elle correspond à la date cible
            if (seance['debutSemaine'] != null) {
              DateTime seanceDate = DateTime.parse(seance['debutSemaine']);
              if (seanceDate.year == targetDate.year && 
                  seanceDate.month == targetDate.month && 
                  seanceDate.day == targetDate.day) {
                filteredSeances.add(Map<String, dynamic>.from(seance));
              }
            }
          }
          
          return ApiResponse(
            success: true,
            message: 'Séances récupérées avec succès',
            data: {'data': filteredSeances},
          );
        }
      }
      
      return ApiResponse(
        success: false,
        message: data['message'] ?? 'Erreur lors de la récupération des séances',
        errors: data['errors'],
      );
    } catch (e) {
      dev.log("Exception: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer des classes par leurs IDs
  Future<ApiResponse> getClassesByIds(List<String> classeIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseURL}/classes/batch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'ids': classeIds}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Classes récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des classes',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
}
