import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/routes.dart';
import '../models/apiResponse.dart';
import '../models/seanceFaiteDto.dart';
import 'UserSessionService.dart';
import 'dart:developer' as dev;

class SeanceFaiteService {
  final UserSessionService _userSessionService = UserSessionService();

  // Marquer une séance comme faite
  Future<ApiResponse> marquerSeanceFaite(String seanceId, SeanceFaiteDto seanceFaiteDto) async {
    try {
      // Vérifier si l'utilisateur est connecté
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      // Vérifier si l'utilisateur est un délégué
      bool estDelegue = false;
      if (userData['data'] != null && 
          userData['data']['details'] != null && 
          userData['data']['details']['estDelegue'] != null) {
        estDelegue = userData['data']['details']['estDelegue'];
      }

      if (!estDelegue) {
        return ApiResponse(
          success: false,
          message: 'Seuls les délégués peuvent marquer les séances comme faites',
        );
      }

      final response = await http.post(
        Uri.parse('${ApiRoutes.baseURL}/api/seance-faite/$seanceId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(seanceFaiteDto.toJson()),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Séance marquée comme faite avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors du marquage de la séance comme faite',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception dans marquerSeanceFaite: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Réinitialiser le statut d'une séance
  Future<ApiResponse> reinitialiserSeanceFaite(String seanceId) async {
    try {
      // Vérifier si l'utilisateur est connecté
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      // Vérifier si l'utilisateur est un délégué
      bool estDelegue = false;
      if (userData['data'] != null && 
          userData['data']['details'] != null && 
          userData['data']['details']['estDelegue'] != null) {
        estDelegue = userData['data']['details']['estDelegue'];
      }

      if (!estDelegue) {
        return ApiResponse(
          success: false,
          message: 'Seuls les délégués peuvent réinitialiser le statut des séances',
        );
      }

      final response = await http.delete(
        Uri.parse('${ApiRoutes.baseURL}/api/seance-faite/$seanceId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Statut de la séance réinitialisé avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la réinitialisation du statut de la séance',
          errors: data['errors'],
        );
      }
    } catch (e) {
      dev.log("Exception dans reinitialiserSeanceFaite: ${e.toString()}", error: e);
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
}
