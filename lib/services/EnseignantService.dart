import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import '../models/apiResponse.dart';
import '../models/EnseignantModel.dart';
import '../core/constants.dart';
import 'UserSessionService.dart';

class EnseignantService {
  final UserSessionService _userSessionService = UserSessionService();
  final String baseUrl = '${ApiRoutes.baseUrl}/api/enseignants';

  // Récupérer tous les enseignants
  Future<ApiResponse> getAllEnseignants() async {
    try {


      final response = await http.get(
        Uri.parse(baseUrl),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des enseignants: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer un enseignant par son ID
  Future<ApiResponse> getEnseignantById(String id) async {
    try {


      final response = await http.get(
        Uri.parse('$baseUrl/$id'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération de l\'enseignant: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer un enseignant par son ID utilisateur
  Future<ApiResponse> getEnseignantByUserId(String userId) async {
    try {


      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération de l\'enseignant par userId: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer les séances d'un enseignant
  Future<ApiResponse> getSeancesByEnseignant(String enseignantId) async {
    try {



      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/seances/enseignant/$enseignantId'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des séances de l\'enseignant: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer plusieurs enseignants par leurs IDs
  Future<ApiResponse> getEnseignantsByIds(List<String> ids) async {
    try {


      final response = await http.post(
        Uri.parse('$baseUrl/batch'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'ids': ids}),
      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des enseignants par IDs: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }
}
