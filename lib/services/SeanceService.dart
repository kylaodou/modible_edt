import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/routes.dart';
import '../models/apiResponse.dart';
import 'UserSessionService.dart';
import 'dart:developer' as dev;

class SeanceService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer l'emploi du t emps pour une classe spécifique et une semaine donnée
  Future<ApiResponse> getEmploiDuTempsParClasseEtSemaine(
      String classeId, DateTime debutSemaine, DateTime finSemaine) async {
    try {
      // Formater les dates au format YYYY-MM-DD
      String debutFormatted = "${debutSemaine.year}-${debutSemaine.month.toString().padLeft(2, '0')}-${debutSemaine.day.toString().padLeft(2, '0')}";
      String finFormatted = "${finSemaine.year}-${finSemaine.month.toString().padLeft(2, '0')}-${finSemaine.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/classe/$classeId/dates/$debutFormatted/$finFormatted'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Emploi du temps récupéré avec succès',
          data: data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération de l\'emploi du temps',
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

  // Récupérer l'emploi du temps pour un enseignant spécifique
  Future<ApiResponse> getSeancesByEnseignant(String enseignantId) async {
    try {
      dev.log("Appel API: /seances/enseignant/$enseignantId");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/enseignant/$enseignantId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      dev.log("Réponse API status: ${response.statusCode}");
      dev.log("Réponse API body: ${response.body}");

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Séances récupérées avec succès',
          data: data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des séances',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception dans getSeancesByEnseignant: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer les séances d'un enseignant pour une période donnée
  Future<ApiResponse> getSeancesByEnseignantAndDateRange(String enseignantId, String startDate, String endDate) async {
    try {
      dev.log("Appel API: /seances/enseignant/$enseignantId");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/enseignant/$enseignantId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      dev.log("Réponse API status: ${response.statusCode}");
      dev.log("Réponse API body: ${response.body}");

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        // Filtrer les séances pour ne garder que celles dans la plage de dates
        List<Map<String, dynamic>> seances = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        // Convertir les dates pour la comparaison
        DateTime start = DateTime.parse(startDate);
        DateTime end = DateTime.parse(endDate);
        
        dev.log("Filtrage des séances du $startDate au $endDate");
        
        // Filtrer les séances en fonction de la date
        List<Map<String, dynamic>> filteredSeances = seances.where((seance) {
          try {
            // Récupérer la date de la séance (format "yyyy-MM-dd")
            String jour = seance['jour'];
            if (jour == null || jour.isEmpty) return false;
            
            DateTime seanceDate = DateTime.parse(jour);
            
            // Vérifier si la date est dans la plage
            bool isInRange = (seanceDate.isAtSameMomentAs(start) || seanceDate.isAfter(start)) && 
                             (seanceDate.isAtSameMomentAs(end) || seanceDate.isBefore(end));
            
            dev.log("Séance du $jour - Dans la plage: $isInRange");
            
            return isInRange;
          } catch (e) {
            dev.log("Erreur lors du filtrage d'une séance: ${e.toString()}", error: e);
            return false;
          }
        }).toList();
        
        dev.log("Nombre de séances après filtrage: ${filteredSeances.length}");
        
        return ApiResponse(
          success: true,
          message: 'Séances récupérées avec succès',
          data: {'data': filteredSeances},
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des séances',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception dans getSeancesByEnseignantAndDateRange: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer l'emploi du temps de l'étudiant connecté
  Future<ApiResponse> getEmploiDuTempsEtudiant(DateTime debutSemaine, DateTime finSemaine) async {
    try {
      dev.log("EDTPage: Début de récupération des séances pour la semaine du ${debutSemaine.toString()} au ${finSemaine.toString()}");
      
      // Récupérer les données de l'utilisateur connecté
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        dev.log("EDTPage: Erreur - Utilisateur non connecté");
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
        dev.log("EDTPage: ClasseId récupéré: $classeId");
      }
      
      if (classeId == null) {
        dev.log("EDTPage: Erreur - Classe de l'étudiant non trouvée");
        return ApiResponse(
          success: false,
          message: 'Classe de l\'étudiant non trouvée',
        );
      }

      // Récupérer toutes les séances
      dev.log("EDTPage: Appel API pour récupérer toutes les séances");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      dev.log("EDTPage: Réponse API reçue: ${response.statusCode}");
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Récupérer toutes les séances
        List<dynamic> allSeances = data['data'] ?? [];
        dev.log("EDTPage: Nombre total de séances récupérées: ${allSeances.length}");
        
        // Afficher les IDs de classe disponibles pour le débogage
        Set<String> classeIds = allSeances
            .where((s) => s['classeId'] != null)
            .map<String>((s) => s['classeId'].toString())
            .toSet();
        dev.log("EDTPage: IDs de classe disponibles dans les données: $classeIds");
        dev.log("EDTPage: ID de classe de l'étudiant connecté: $classeId");
        
        // Filtrer les séances par date
        List<Map<String, dynamic>> filteredSeances = [];
        for (var seance in allSeances) {
          // Vérifier si la séance est dans la semaine demandée
          if (seance['debutSemaine'] != null && seance['finSemaine'] != null) {
            DateTime debutSeance = DateTime.parse(seance['debutSemaine']);
            DateTime finSeance = DateTime.parse(seance['finSemaine']);
            
            // Vérifier si la période de la séance chevauche la période demandée
            bool estDansLaSemaine = (
              (debutSeance.isBefore(finSemaine) || debutSeance.isAtSameMomentAs(finSemaine)) && 
              (finSeance.isAfter(debutSemaine) || finSeance.isAtSameMomentAs(debutSemaine))
            );
            
            if (estDansLaSemaine) {
              // Convertir en Map<String, dynamic>
              filteredSeances.add(Map<String, dynamic>.from(seance));
              
              // Afficher les détails de chaque séance pour le débogage
              dev.log("EDTPage: Séance ajoutée - ID: ${seance['id']}, classeId: ${seance['classeId']}, jour: ${seance['jour']}");
            }
          }
        }
        
        dev.log("EDTPage: Nombre de séances après traitement: ${filteredSeances.length}");
        
        return ApiResponse(
          success: true,
          message: 'Séances récupérées avec succès',
          data: {
            'data': filteredSeances
          },
        );
      } else {
        dev.log("EDTPage: Erreur API: ${data['message'] ?? 'Erreur inconnue'}");
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des séances',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("EDTPage: Exception: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer toutes les salles
  Future<ApiResponse> getAllSalles() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/salles'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Salles récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des salles',
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

  // Récupérer tous les cours
  Future<ApiResponse> getAllCours() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/cours'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Cours récupérés avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des cours',
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

  // Récupérer des cours par leurs IDs
  Future<ApiResponse> getCoursByIds(List<String> coursIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseURL}/cours/batch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'ids': coursIds}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Cours récupérés avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des cours',
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

  // Récupérer des salles par leurs IDs
  Future<ApiResponse> getSallesByIds(List<String> salleIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseURL}/salles/batch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'ids': salleIds}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Salles récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des salles',
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

  // Récupérer des classes par leurs IDs
  Future<ApiResponse> getClassesByIds(List<String> classeIds) async {
    try {
      dev.log("Appel API: /classes/batch avec IDs: $classeIds");
      
      if (classeIds.isEmpty) {
        dev.log("Aucun ID de classe fourni, retour d'une liste vide");
        return ApiResponse(
          success: true,
          message: 'Aucune classe à récupérer',
          data: [],
        );
      }
      
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseURL}/classes/batch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'ids': classeIds}),
      );

      dev.log("Réponse API status: ${response.statusCode}");
      dev.log("Réponse API body: ${response.body}");

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        dev.log("Nombre de classes récupérées: ${(data['data'] ?? []).length}");
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
      dev.log("Exception dans getClassesByIds: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer tous les enseignants
  Future<ApiResponse> getAllEnseignants() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/enseignants'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Enseignants récupérés avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des enseignants',
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

  // Récupérer tous les créneaux horaires
  Future<ApiResponse> getAllCreneaux() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/creneaux'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Créneaux récupérés avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des créneaux',
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

  // Récupérer toutes les classes
  Future<ApiResponse> getAllClasses() async {
    try {
      dev.log("Appel API: /classes");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/classes'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      dev.log("Réponse API status: ${response.statusCode}");
      dev.log("Réponse API body: ${response.body}");

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        dev.log("Nombre total de classes récupérées: ${(data['data'] ?? []).length}");
        // Afficher les IDs des classes récupérées pour le débogage
        for (var classe in data['data'] ?? []) {
          dev.log("Classe ID: ${classe['id']}, Nom: ${classe['nom']}");
        }
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
      dev.log("Exception dans getAllClasses: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer une classe par son ID
  Future<ApiResponse> getClasseById(String classeId) async {
    try {
      dev.log("Appel API: /classes/$classeId");
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/classes/$classeId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      dev.log("Réponse API status: ${response.statusCode}");
      dev.log("Réponse API body: ${response.body}");

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        dev.log("Classe récupérée: ${data['data']['nom']}");
        return ApiResponse(
          success: true,
          message: 'Classe récupérée avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération de la classe',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception dans getClasseById: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Confirmer une séance
  Future<ApiResponse> confirmerSeance(String seanceId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/seances/$seanceId/confirmer'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Séance confirmée avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la confirmation de la séance',
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

  // Annuler une séance avec justification
  Future<ApiResponse> annulerSeance(String seanceId, String justification) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/seances/$seanceId/annuler'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'justification': justification}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Séance annulée avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de l\'annulation de la séance',
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
