import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';

class ClasseService {
  // Méthode pour encoder correctement les données en UTF-8
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
  }

  // Récupérer les informations d'une classe par son ID
  Future<ApiResponse> getClasseById(String classeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/classes/$classeId'),
        headers: _getHeaders(),
      );

      final responseData = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Informations classe récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des informations de la classe',
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
