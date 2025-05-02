// lib/services/userSessionService.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modible_edt/models/userSessionModel.dart';
import 'package:modible_edt/models/userModel.dart';
import '../core/routes.dart';

class UserSessionService {
  static const String USER_KEY = 'user_data';

  // Sauvegarder la session utilisateur
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, jsonEncode(userData));
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(USER_KEY);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  // Récupérer l'objet UserSessionModel complet
  Future<UserSessionModel?> getUserSession() async {
    Map<String, dynamic>? userData = await getUserData();
    if (userData == null) return null;

    // Si les données sont dans le format de l'API
    if (userData.containsKey('data') &&
        userData['data'] is Map<String, dynamic> &&
        userData['data'].containsKey('user') &&
        userData['data'].containsKey('details')) {
      return UserSessionModel.fromJson(userData['data']);
    }

    // Si les données sont déjà dans le bon format
    if (userData.containsKey('user') && userData.containsKey('details')) {
      return UserSessionModel.fromJson(userData);
    }

    // Format ancien - créer un UserModel simple
    UserModel user = UserModel.fromJson(userData);
    return UserSessionModel(user: user);
  }

  // Supprimer la session
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_KEY);
  }
  
  // Rafraîchir les données utilisateur depuis le serveur
  Future<bool> refreshUserData() async {
    try {
      Map<String, dynamic>? userData = await getUserData();
      if (userData == null) {
        dev.log("Impossible de rafraîchir les données: utilisateur non connecté");
        return false;
      }
      
      String? userId;
      if (userData['data'] != null && userData['data']['user'] != null && userData['data']['user']['id'] != null) {
        userId = userData['data']['user']['id'];
      } else if (userData['user'] != null && userData['user']['id'] != null) {
        userId = userData['user']['id'];
      }
      
      if (userId == null) {
        dev.log("Impossible de rafraîchir les données: ID utilisateur non trouvé");
        return false;
      }
      
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/users/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          // Mettre à jour les données utilisateur
          await saveUserSession(data);
          dev.log("Données utilisateur rafraîchies avec succès");
          return true;
        }
      }
      
      dev.log("Échec du rafraîchissement des données utilisateur: ${response.statusCode}");
      return false;
    } catch (e) {
      dev.log("Exception lors du rafraîchissement des données utilisateur: ${e.toString()}", error: e);
      return false;
    }
  }
}