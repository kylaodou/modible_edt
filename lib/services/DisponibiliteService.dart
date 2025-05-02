import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modible_edt/core/routes.dart';
import '../models/apiResponse.dart';
import '../models/DisponibiliteModel.dart';
import '../core/constants.dart';
import 'UserSessionService.dart';

class DisponibiliteService {
  final UserSessionService _userSessionService = UserSessionService();
  final String baseUrl = '${ApiRoutes.baseUrl}/api/disponibilites';

  // Créer une nouvelle disponibilité
  Future<ApiResponse> createDisponibilite(DisponibiliteModel disponibilite) async {
    try {
      


      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jour': disponibilite.jour,
          'creneauId': disponibilite.creneauId,
          'enseignantId': disponibilite.enseignantId,
          'disponible': disponibilite.disponible,
          'commentaire': disponibilite.commentaire,
          'debutSemaine': disponibilite.debutSemaine?.toIso8601String(),
          'finSemaine': disponibilite.finSemaine?.toIso8601String(),
        }),
      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la création de la disponibilité: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer toutes les disponibilités
  Future<ApiResponse> getAllDisponibilites() async {
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
      dev.log('Erreur lors de la récupération des disponibilités: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer les disponibilités par enseignant
  Future<ApiResponse> getDisponibilitesByEnseignant(String enseignantId) async {
    try {


      final response = await http.get(
        Uri.parse('$baseUrl/enseignant/$enseignantId'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des disponibilités par enseignant: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer les disponibilités par semaine
  Future<ApiResponse> getDisponibilitesBySemaine(DateTime debutSemaine, DateTime finSemaine) async {
    try {


      final formatter = DateFormat('yyyy-MM-dd');
      final debutFormatted = formatter.format(debutSemaine);
      final finFormatted = formatter.format(finSemaine);

      final response = await http.get(
        Uri.parse('$baseUrl/semaine?debutSemaine=$debutFormatted&finSemaine=$finFormatted'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des disponibilités par semaine: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Récupérer les disponibilités par enseignant et semaine
  Future<ApiResponse> getDisponibilitesByEnseignantAndSemaine(
      String enseignantId, DateTime debutSemaine, DateTime finSemaine) async {
    try {


      final formatter = DateFormat('yyyy-MM-dd');
      final debutFormatted = formatter.format(debutSemaine);
      final finFormatted = formatter.format(finSemaine);

      final response = await http.get(
        Uri.parse('$baseUrl/enseignant/$enseignantId/semaine?debutSemaine=$debutFormatted&finSemaine=$finFormatted'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la récupération des disponibilités par enseignant et semaine: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Mettre à jour une disponibilité
  Future<ApiResponse> updateDisponibilite(String id, DisponibiliteModel disponibilite) async {
    try {



      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jour': disponibilite.jour,
          'creneauId': disponibilite.creneauId,
          'enseignantId': disponibilite.enseignantId,
          'disponible': disponibilite.disponible,
          'commentaire': disponibilite.commentaire,
          'debutSemaine': disponibilite.debutSemaine?.toIso8601String(),
          'finSemaine': disponibilite.finSemaine?.toIso8601String(),
        }),
      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la mise à jour de la disponibilité: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // Supprimer une disponibilité
  Future<ApiResponse> deleteDisponibilite(String id) async {
    try {


      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),

      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Erreur inconnue',
        data: responseData['data'],
      );
    } catch (e) {
      dev.log('Erreur lors de la suppression de la disponibilité: ${e.toString()}', error: e);
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }
}
