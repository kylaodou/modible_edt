import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/models/userModel.dart';
import 'package:modible_edt/services/userSessionService.dart';

class UserService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer tous les utilisateurs
  Future<ApiResponse> getAllUsers() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits d'admin
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateurs récupérés avec succès';
        
        if (responseData['data'] != null) {
          List<dynamic> usersData = responseData['data'];
          List<UserModel> users = usersData
              .map((item) => UserModel.fromJson(item))
              .toList();
          apiResponse.data = users;
        } else {
          apiResponse.data = [];
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération des utilisateurs';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Récupérer les utilisateurs inactifs (en attente de validation)
  Future<ApiResponse> getInactiveUsers() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits d'admin
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.get(
        Uri.parse(ApiRoutes.inactiveUsersURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateurs inactifs récupérés avec succès';
        
        if (responseData['data'] != null) {
          List<dynamic> usersData = responseData['data'];
          List<UserModel> users = usersData
              .map((item) => UserModel.fromJson(item))
              .toList();
          apiResponse.data = users;
        } else {
          apiResponse.data = [];
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération des utilisateurs inactifs';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Récupérer un utilisateur par son ID
  Future<ApiResponse> getUserById(String id) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(
        Uri.parse(ApiRoutes.getUserById(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur récupéré avec succès';
        
        if (responseData['data'] != null) {
          UserModel user = UserModel.fromJson(responseData['data']);
          apiResponse.data = user;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Récupérer un utilisateur par son email
  Future<ApiResponse> getUserByEmail(String email) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(
        Uri.parse(ApiRoutes.getUserByEmail(email)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur récupéré avec succès';
        
        if (responseData['data'] != null) {
          UserModel user = UserModel.fromJson(responseData['data']);
          apiResponse.data = user;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Mettre à jour un utilisateur
  Future<ApiResponse> updateUser(String id, UserModel user) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits pour mettre à jour
      final userData = await _userSessionService.getUserData();
      if (userData == null) {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'êtes pas connecté';
        return apiResponse;
      }

      // Vérifier si l'utilisateur modifie son propre profil ou s'il est admin
      if (userData['id'] != id && userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse(ApiRoutes.updateUser(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur mis à jour avec succès';
        
        if (responseData['data'] != null) {
          UserModel updatedUser = UserModel.fromJson(responseData['data']);
          apiResponse.data = updatedUser;
          
          // Si l'utilisateur met à jour son propre profil, mettre à jour la session
          if (userData['id'] == id) {
            await _userSessionService.saveUserSession(responseData['data']);
          }
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la mise à jour de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
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
  Future<ApiResponse> updateProfilePhoto(String id, String base64Image) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits pour mettre à jour
      final userData = await _userSessionService.getUserData();
      if (userData == null) {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'êtes pas connecté';
        return apiResponse;
      }

      // Vérifier si l'utilisateur modifie son propre profil ou s'il est admin
      if (userData['id'] != id && userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse(ApiRoutes.updateUserPhoto(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'photo': base64Image,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Photo de profil mise à jour avec succès';
        
        if (responseData['photoUrl'] != null) {
          apiResponse.data = responseData['photoUrl'];
          
          // Si l'utilisateur met à jour sa propre photo, mettre à jour la session
          if (userData['id'] == id) {
            userData['photo'] = responseData['photoUrl'];
            await _userSessionService.saveUserSession(userData);
          }
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la mise à jour de la photo de profil';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Valider un utilisateur (activer son compte)
  Future<ApiResponse> validateUser(String id) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits d'admin
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse(ApiRoutes.validateUser(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur validé avec succès';
        
        if (responseData['data'] != null) {
          UserModel user = UserModel.fromJson(responseData['data']);
          apiResponse.data = user;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la validation de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Invalider un utilisateur (désactiver son compte)
  Future<ApiResponse> invalidateUser(String id) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits d'admin
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.put(
        Uri.parse(ApiRoutes.invalidateUser(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur invalidé avec succès';
        
        if (responseData['data'] != null) {
          UserModel user = UserModel.fromJson(responseData['data']);
          apiResponse.data = user;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de l\'invalidation de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }

  // Supprimer un utilisateur
  Future<ApiResponse> deleteUser(String id) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Vérifier si l'utilisateur est connecté et a les droits d'admin
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['role'] != 'ADMIN' && userData['role'] != 'SUPER_ADMIN') {
        apiResponse.success = false;
        apiResponse.message = 'Vous n\'avez pas les droits pour effectuer cette action';
        return apiResponse;
      }

      final response = await http.delete(
        Uri.parse(ApiRoutes.deleteUser(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Utilisateur supprimé avec succès';
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la suppression de l\'utilisateur';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
    }
    return apiResponse;
  }
}
