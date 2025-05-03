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
      
      // Récupérer d'abord tous les cours de l'enseignant
      final coursResponse = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/cours/enseignant/$enseignantId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      final coursData = jsonDecode(utf8.decode(coursResponse.bodyBytes));
      dev.log("Réponse API cours: ${coursResponse.statusCode}");
      dev.log("Nombre de cours récupérés: ${coursData['data']?.length ?? 0}");
      
      if (coursResponse.statusCode != 200 || coursData['success'] != true) {
        dev.log("Erreur lors de la récupération des cours: ${coursData['message'] ?? 'Erreur inconnue'}");
        return ApiResponse(
          success: false,
          message: coursData['message'] ?? 'Erreur lors de la récupération des cours',
          errors: coursData['errors'],
        );
      }
      
      // Extraire les IDs des cours enseignés par cet enseignant
      List<String> coursIds = [];
      if (coursData['data'] != null) {
        for (var cours in coursData['data']) {
          if (cours['id'] != null) {
            coursIds.add(cours['id']);
            dev.log("Cours trouvé: ${cours['code']} - ${cours['intitule']}");
          }
        }
      }
      
      if (coursIds.isEmpty) {
        dev.log("Aucun cours trouvé pour l'enseignant $enseignantId");
        return ApiResponse(
          success: true,
          message: 'Aucun cours trouvé pour cet enseignant',
          data: {'data': []},
        );
      }
      
      // Récupérer toutes les séances
      final seancesResponse = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      final seancesData = jsonDecode(utf8.decode(seancesResponse.bodyBytes));
      dev.log("Réponse API séances: ${seancesResponse.statusCode}");
      
      if (seancesResponse.statusCode != 200 || seancesData['success'] != true) {
        dev.log("Erreur lors de la récupération des séances: ${seancesData['message'] ?? 'Erreur inconnue'}");
        return ApiResponse(
          success: false,
          message: seancesData['message'] ?? 'Erreur lors de la récupération des séances',
          errors: seancesData['errors'],
        );
      }
      
      // Filtrer les séances pour ne garder que celles des cours de l'enseignant
      List<Map<String, dynamic>> filteredSeances = [];
      
      if (seancesData['data'] != null) {
        // Convertir la date spécifiée en objet DateTime pour la comparaison
        DateTime targetDate = DateTime.parse(date);
        String targetDay = _getDayOfWeek(targetDate);
        dev.log("Jour cible: $targetDay, Date cible: $date");
        
        for (var seance in seancesData['data']) {
          // Vérifier si la séance correspond à un cours de l'enseignant
          if (seance['coursId'] != null && coursIds.contains(seance['coursId'])) {
            // Vérifier si c'est le bon jour de la semaine
            if (seance['jour'] != null && 
                seance['jour'].toString().toLowerCase() == targetDay.toLowerCase()) {
              
              // Vérifier si la séance est dans la plage de dates actuelle
              if (seance['debutSemaine'] != null && seance['finSemaine'] != null) {
                try {
                  DateTime debutSemaine = DateTime.parse(seance['debutSemaine']);
                  DateTime finSemaine = DateTime.parse(seance['finSemaine']);
                  
                  if (targetDate.isAfter(debutSemaine.subtract(Duration(days: 1))) && 
                      targetDate.isBefore(finSemaine.add(Duration(days: 1)))) {
                    filteredSeances.add(Map<String, dynamic>.from(seance));
                    dev.log("Séance ajoutée: ${seance['id']}, cours: ${seance['coursId']}, jour: ${seance['jour']}, créneau: ${seance['creneau']}");
                  }
                } catch (e) {
                  dev.log("Erreur de parsing de date: ${e.toString()}", error: e);
                }
              }
            }
          }
        }
      }
      
      dev.log("Nombre de séances filtrées: ${filteredSeances.length}");
      
      return ApiResponse(
        success: true,
        message: 'Séances récupérées avec succès',
        data: {'data': filteredSeances},
      );
    } catch (e) {
      dev.log("Exception: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
  
  // Fonction utilitaire pour obtenir le jour de la semaine en français
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1: return 'lundi';
      case 2: return 'mardi';
      case 3: return 'mercredi';
      case 4: return 'jeudi';
      case 5: return 'vendredi';
      case 6: return 'samedi';
      case 7: return 'dimanche';
      default: return '';
    }
  }

  // Récupérer des classes par leurs IDs
  Future<ApiResponse> getClassesByIds(List<String> classeIds) async {
    try {
      dev.log("Récupération des classes pour les IDs: $classeIds");
      
      // Construire les requêtes pour chaque ID
      List<Future<http.Response>> requests = [];
      for (String id in classeIds) {
        requests.add(http.get(
          Uri.parse('${ApiRoutes.baseURL}/classes/$id'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ));
      }
      
      // Exécuter toutes les requêtes en parallèle
      List<http.Response> responses = await Future.wait(requests);
      
      // Traiter les réponses
      List<Map<String, dynamic>> classes = [];
      for (int i = 0; i < responses.length; i++) {
        http.Response response = responses[i];
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['success'] == true && data['data'] != null) {
            classes.add(Map<String, dynamic>.from(data['data']));
          }
        }
      }
      
      return ApiResponse(
        success: true,
        message: 'Classes récupérées avec succès',
        data: classes,
      );
    } catch (e) {
      dev.log("Erreur lors de la récupération des classes: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
}
