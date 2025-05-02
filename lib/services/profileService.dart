import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/userSessionService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../models/userModel.dart';

class ProfileService {
  final UserSessionService _userSessionService = UserSessionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour encoder correctement les données en UTF-8
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
  }

  // Récupérer les informations du profil de l'utilisateur connecté
  Future<ApiResponse> getUserProfile() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Récupérer les données de l'utilisateur connecté
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['id'] == null) {
        apiResponse.success = false;
        apiResponse.message = 'Utilisateur non connecté';
        return apiResponse;
      }

      final userId = userData['id'];
      final response = await http.get(
        Uri.parse(ApiRoutes.getUserById(userId)),
        headers: _getHeaders(),
      );

      final responseData = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        apiResponse.success = data['success'] ?? true;
        apiResponse.message = data['message'] ?? 'Profil récupéré avec succès';
        
        if (data['data'] != null) {
          UserModel user = UserModel.fromJson(data['data']);
          apiResponse.data = user;
          
          // Mettre à jour les données de session avec les données les plus récentes
          await _userSessionService.saveUserSession(data['data']);
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = data['message'] ?? 'Erreur lors de la récupération du profil';
        apiResponse.errors = data['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Mettre à jour la photo de profil
  Future<ApiResponse> updateProfilePhoto(File imageFile) async {
    try {
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      String? userId = userData['data']['user']['id'];
      
      if (userId == null) {
        return ApiResponse(
          success: false,
          message: 'ID utilisateur non trouvé',
        );
      }

      // Créer un FormData pour   envoyer le fichier
      var request = http.MultipartRequest(
        'PUT', 
        Uri.parse('${ApiRoutes.baseURL}/users/$userId/photo')
      );
      
      // Ajouter le fichier à la requête
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        )
      );

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Traiter la réponse
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        // Récupérer l'URL de la photo téléchargée
        String? photoUrl = data['photoUrl'];
        
        // Mettre à jour les données de session
        if (userData['data']['user'] != null && photoUrl != null) {
          userData['data']['user']['photoURL'] = photoUrl;
          await _userSessionService.saveUserSession(userData);
        }

        return ApiResponse(
          success: true,
          message: 'Photo de profil mise à jour avec succès',
          data: photoUrl,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la mise à jour de la photo',
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

  // Changer le mot de passe
  Future<ApiResponse> changePassword(String currentPassword, String newPassword) async {
    try {
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      String? userId = userData['data']['user']['id'];
      String? email = userData['data']['user']['email'];
      
      if (userId == null || email == null) {
        return ApiResponse(
          success: false,
          message: 'Informations utilisateur incomplètes',
        );
      }

      // Vérifier l'authentification avec le mot de passe actuel
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: currentPassword,
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Mot de passe actuel incorrect',
        );
      }

      // Mettre à jour le mot de passe Firebase
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);

      // Mettre à jour le mot de passe dans l'API
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/api/etudiants/$userId/password'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: 'Mot de passe mis à jour avec succès',
        );
      } else {
        // Si l'API échoue mais que Firebase a réussi, nous considérons que c'est un succès
        return ApiResponse(
          success: true,
          message: 'Mot de passe mis à jour avec succès (Firebase uniquement)',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur lors de la mise à jour du mot de passe: ${e.toString()}',
      );
    }
  }

  // Mettre à jour les préférences de notification
  Future<ApiResponse> updateNotificationPreferences(bool enabled) async {
    try {
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      String? userId = userData['data']['user']['id'];
      
      if (userId == null) {
        return ApiResponse(
          success: false,
          message: 'ID utilisateur non trouvé',
        );
      }

      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/api/etudiants/$userId/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'notificationsEnabled': enabled,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        // Mettre à jour les données de session
        if (userData['data']['user'] != null) {
          userData['data']['user']['notificationsEnabled'] = enabled;
          await _userSessionService.saveUserSession(userData);
        }

        return ApiResponse(
          success: true,
          message: 'Préférences de notification mises à jour avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la mise à jour des préférences',
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

  // Mettre à jour les préférences détaillées de notification
  Future<ApiResponse> updateDetailedNotificationPreferences(Map<String, bool> preferences) async {
    try {
      Map<String, dynamic>? userData = await _userSessionService.getUserData();
      
      if (userData == null) {
        return ApiResponse(
          success: false,
          message: 'Utilisateur non connecté',
        );
      }

      String? userId = userData['data']['user']['id'];
      
      if (userId == null) {
        return ApiResponse(
          success: false,
          message: 'ID utilisateur non trouvé',
        );
      }

      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/api/etudiants/$userId/notifications/preferences'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'preferences': preferences,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        // Mettre à jour les données de session
        if (userData['data']['user'] != null) {
          userData['data']['user']['notificationPreferences'] = preferences;
          await _userSessionService.saveUserSession(userData);
        }

        return ApiResponse(
          success: true,
          message: 'Préférences détaillées de notification mises à jour avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la mise à jour des préférences détaillées',
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

  // Déconnexion
  Future<ApiResponse> logout() async {
    try {
      // Déconnexion de Firebase
      await FirebaseAuth.instance.signOut();
      
      // Déconnexion de Google si connecté
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      // Déconnexion de Facebook si connecté
      await FacebookAuth.instance.logOut();
      
      // Effacer les données de session
      await _userSessionService.clearUserSession();
      
      return ApiResponse(
        success: true,
        message: 'Déconnexion réussie',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur lors de la déconnexion: ${e.toString()}',
      );
    }
  }

  // Récupérer les informations complètes de l'étudiant (avec classe et filière)
  Future<ApiResponse> getEtudiantComplet() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Récupérer les données de l'utilisateur connecté
      final userData = await _userSessionService.getUserData();
      if (userData == null) {
        apiResponse.success = false;
        apiResponse.message = 'Utilisateur non connecté';
        return apiResponse;
      }
      
      // Vérifier si l'utilisateur a un ID
      String? userId;
      if (userData['data'] != null && userData['data']['user'] != null) {
        userId = userData['data']['user']['id'];
      }
      
      if (userId == null) {
        apiResponse.success = false;
        apiResponse.message = 'ID utilisateur non trouvé';
        return apiResponse;
      }
      
      // Récupérer les informations de l'étudiant
      final etudiantResponse = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/etudiants/user/$userId'),
        headers: _getHeaders(),
      );
      
      final etudiantData = jsonDecode(utf8.decode(etudiantResponse.bodyBytes));
      
      if (etudiantResponse.statusCode != 200 || etudiantData['success'] != true) {
        apiResponse.success = false;
        apiResponse.message = etudiantData['message'] ?? 'Erreur lors de la récupération des informations étudiant';
        return apiResponse;
      }
      
      // Récupérer l'étudiant
      final etudiant = etudiantData['data'];
      
      // Récupérer les informations de la classe
      final classeId = etudiant['classeId'];
      if (classeId == null) {
        // Retourner seulement les informations de l'étudiant si la classe n'est pas définie
        apiResponse.success = true;
        apiResponse.message = 'Informations étudiant récupérées avec succès (sans classe)';
        apiResponse.data = {
          'etudiant': etudiant,
          'classe': null,
          'filiere': null
        };
        return apiResponse;
      }
      
      final classeResponse = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/classes/$classeId'),
        headers: _getHeaders(),
      );
      
      final classeData = jsonDecode(utf8.decode(classeResponse.bodyBytes));
      
      if (classeResponse.statusCode != 200 || classeData['success'] != true) {
        // Retourner seulement les informations de l'étudiant si la classe n'a pas pu être récupérée
        apiResponse.success = true;
        apiResponse.message = 'Informations étudiant récupérées avec succès (sans classe)';
        apiResponse.data = {
          'etudiant': etudiant,
          'classe': null,
          'filiere': null
        };
        return apiResponse;
      }
      
      // Récupérer la classe
      final classe = classeData['data'];
      
      // Récupérer les informations de la filière
      final filiereId = classe['filiereId'];
      if (filiereId == null) {
        // Retourner les informations de l'étudiant et de la classe si la filière n'est pas définie
        apiResponse.success = true;
        apiResponse.message = 'Informations étudiant récupérées avec succès (sans filière)';
        apiResponse.data = {
          'etudiant': etudiant,
          'classe': classe,
          'filiere': null
        };
        return apiResponse;
      }
      
      final filiereResponse = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/filieres/$filiereId'),
        headers: _getHeaders(),
      );
      
      final filiereData = jsonDecode(utf8.decode(filiereResponse.bodyBytes));
      
      if (filiereResponse.statusCode != 200 || filiereData['success'] != true) {
        // Retourner les informations de l'étudiant et de la classe si la filière n'a pas pu être récupérée
        apiResponse.success = true;
        apiResponse.message = 'Informations étudiant récupérées avec succès (sans filière)';
        apiResponse.data = {
          'etudiant': etudiant,
          'classe': classe,
          'filiere': null
        };
        return apiResponse;
      }
      
      // Récupérer la filière
      final filiere = filiereData['data'];
      
      // Retourner toutes les informations
      apiResponse.success = true;
      apiResponse.message = 'Informations complètes récupérées avec succès';
      apiResponse.data = {
        'etudiant': etudiant,
        'classe': classe,
        'filiere': filiere
      };
      
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Récupérer les informations d'un enseignant par son userId
  Future<ApiResponse> getEnseignantByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/enseignants/user/$userId'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Données de l\'enseignant récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des données de l\'enseignant',
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
