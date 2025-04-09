import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  static const String USER_KEY = 'user_data';
  static const String IS_LOGGED_IN = 'is_logged_in';

  // Enregistrer les données de l'utilisateur
  Future<bool> saveUserSession(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(IS_LOGGED_IN, true);
      await prefs.setString(USER_KEY, jsonEncode(userData));
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde de la session: $e');
      return false;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(IS_LOGGED_IN) ?? false;
    } catch (e) {
      print('Erreur lors de la vérification de la session: $e');
      return false;
    }
  }

  // Récupérer les données de l'utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString(USER_KEY);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Déconnexion - effacer les données de session
  Future<bool> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(IS_LOGGED_IN, false);
      await prefs.remove(USER_KEY);
      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return false;
    }
  }
}
