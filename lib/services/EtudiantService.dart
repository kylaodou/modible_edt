import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/userSessionService.dart';

class EtudiantService {
  final UserSessionService _userSessionService = UserSessionService();

  // Méthode pour encoder correctement les données en UTF-8
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
  }

  // Récupérer les informations de l'étudiant connecté
  Future<ApiResponse> getEtudiantConnecte() async {
    try {
      // Récupérer les données de l'utilisateur connecté
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null || userData['data'] == null || userData['data']['user'] == null) {
        return ApiResponse(
          success: false,
          message: 'Aucune session utilisateur trouvée',
        );
      }

      // Récupérer l'ID de l'utilisateur
      String? userId = userData['data']['user']['id'];
      
      if (userId == null) {
        return ApiResponse(
          success: false,
          message: 'ID utilisateur non trouvé',
        );
      }

      // Appeler l'API pour récupérer les informations de l'étudiant
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/etudiants/user/$userId'),
        headers: _getHeaders(),
      );

      final responseData = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Informations étudiant récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des informations étudiant',
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
