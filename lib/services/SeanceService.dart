import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/routes.dart';
import '../models/apiResponse.dart';
import 'UserSessionService.dart';
import 'dart:developer' as dev;

class SeanceService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer l'emploi du temps pour une classe spécifique et une semaine donnée
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
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/enseignant/$enseignantId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

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
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Récupérer l'emploi du temps pour un enseignant spécifique et une plage de dates
  Future<ApiResponse> getSeancesByEnseignantAndDateRange(String enseignantId, String startDate, String endDate) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/seances/enseignant/$enseignantId/dates/$startDate/$endDate'),
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

  // Confirmer une séance (marquer comme faite)
  Future<ApiResponse> confirmerSeance(String seanceId, String commentaire) async {
    try {
      dev.log("Confirmation de la séance $seanceId avec commentaire: $commentaire");
      
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/seances/$seanceId/confirmer'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'fait': true,
          'commentaire': commentaire,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      dev.log("Réponse de l'API: ${response.statusCode}, ${data.toString()}");

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
      dev.log("Erreur lors de la confirmation de la séance: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Annuler une séance
  Future<ApiResponse> annulerSeance(String seanceId, String justification) async {
    try {
      dev.log("Annulation de la séance $seanceId avec justification: $justification");
      
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/seances/$seanceId/annuler'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'statut': 'Annulée',
          'commentaire': justification,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      dev.log("Réponse de l'API: ${response.statusCode}, ${data.toString()}");

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
      dev.log("Erreur lors de l'annulation de la séance: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Vérifier si une séance est passée (pour empêcher la modification après l'heure)
  bool isSeancePassed(Map<String, dynamic> seance) {
    try {
      // Récupérer le jour et le créneau de la séance
      String jour = seance['jour']?.toString().toLowerCase() ?? '';
      String creneau = seance['creneau']?.toString() ?? '';
      
      // Convertir le jour en numéro de jour de la semaine (1 = lundi, 7 = dimanche)
      int jourNum;
      switch (jour) {
        case 'lundi': jourNum = 1; break;
        case 'mardi': jourNum = 2; break;
        case 'mercredi': jourNum = 3; break;
        case 'jeudi': jourNum = 4; break;
        case 'vendredi': jourNum = 5; break;
        case 'samedi': jourNum = 6; break;
        case 'dimanche': jourNum = 7; break;
        default: jourNum = 0; break;
      }
      
      if (jourNum == 0) {
        dev.log("Jour invalide: $jour");
        return false; // Si le jour est invalide, on considère que la séance n'est pas passée
      }
      
      // Extraire l'heure de fin du créneau (format: "8H-12H" ou "14H-18H")
      String heureFinStr = '';
      if (creneau.contains('-')) {
        heureFinStr = creneau.split('-')[1].trim();
      }
      
      if (heureFinStr.isEmpty) {
        dev.log("Format de créneau invalide: $creneau");
        return false; // Si le format du créneau est invalide, on considère que la séance n'est pas passée
      }
      
      // Convertir l'heure de fin en entier (ex: "12H" -> 12)
      int heureFin = int.tryParse(heureFinStr.replaceAll('H', '')) ?? 0;
      
      if (heureFin == 0) {
        dev.log("Heure de fin invalide: $heureFinStr");
        return false; // Si l'heure de fin est invalide, on considère que la séance n'est pas passée
      }
      
      // Récupérer la date et l'heure actuelles
      DateTime now = DateTime.now();
      int jourActuel = now.weekday; // 1 = lundi, 7 = dimanche
      int heureActuelle = now.hour;
      
      // Vérifier si la séance est passée
      if (jourActuel > jourNum) {
        // Si le jour actuel est après le jour de la séance, la séance est passée
        return true;
      } else if (jourActuel == jourNum && heureActuelle >= heureFin) {
        // Si c'est le même jour et l'heure actuelle est après l'heure de fin, la séance est passée
        return true;
      }
      
      // La séance n'est pas encore passée
      return false;
    } catch (e) {
      dev.log("Erreur lors de la vérification si la séance est passée: ${e.toString()}", error: e);
      return false; // En cas d'erreur, on considère que la séance n'est pas passée
    }
  }
}
