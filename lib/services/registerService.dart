import 'dart:convert';

import 'package:modible_edt/core/constants.dart';

import 'package:modible_edt/utils/roles.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../core/routes.dart';
import '../models/apiResponse.dart';
import '../models/userModel.dart';

//inscription avec email et password
Future<ApiResponse> inscription(UserModel user) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Vérification des champs obligatoires
    if (user.email == null || user.email!.isEmpty) {
      apiResponse.success = false;
      apiResponse.message = 'L\'email est obligatoire';
      apiResponse.errors = {'email': 'L\'email est obligatoire'};
      return apiResponse;
    }

    if (user.password == null || user.password!.isEmpty) {
      apiResponse.success = false;
      apiResponse.message = 'Le mot de passe est obligatoire';
      apiResponse.errors = {'password': 'Le mot de passe est obligatoire'};
      return apiResponse;
    }

    // Définir le rôle par défaut comme ETUDIANT si non spécifié
    if (user.role == null) {
      user.role = Roles.ETUDIANT;
    }

    // Créer un objet Map simple pour l'envoi
    Map<String, dynamic> requestData = {
      'email': user.email,
      'password': user.password,
      'role': user.role
    };

    final response = await http.post(
      Uri.parse(ApiRoutes.inscriptionURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final responseData = jsonDecode(response.body);
    apiResponse.success = responseData['success'] ?? false;
    apiResponse.message = responseData['message'] ?? 'Une erreur est survenue';

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['data'] != null) {
        apiResponse.data = UserModel.fromJson(responseData['data']);
      }
    } else {
      apiResponse.errors = responseData['errors'];
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion: ${e.toString()}';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}

//verifier le code de vérification pour confirmer le compte
Future<ApiResponse> verifyCode(String email, String code) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Vérification des champs obligatoires
    if (email.isEmpty) {
      apiResponse.success = false;
      apiResponse.message = 'L\'email est obligatoire';
      apiResponse.errors = {'email': 'L\'email est obligatoire'};
      return apiResponse;
    }

    if (code.isEmpty) {
      apiResponse.success = false;
      apiResponse.message = 'Le code de vérification est obligatoire';
      apiResponse.errors = {'code': 'Le code de vérification est obligatoire'};
      return apiResponse;
    }

    // Créer un objet Map simple pour l'envoi
    Map<String, String> requestData = {
      'email': email,
      'code': code,
    };

    final response = await http.post(
      Uri.parse(ApiRoutes.verifyCodeURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final responseData = jsonDecode(response.body);
    apiResponse.success = responseData['success'] ?? false;
    apiResponse.message = responseData['message'] ?? 'Une erreur est survenue';

    if (response.statusCode == 200) {
      if (responseData['data'] != null) {
        apiResponse.data = UserModel.fromJson(responseData['data']);
      }
    } else {
      apiResponse.errors = responseData['errors'];
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion: ${e.toString()}';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}

//pour redemander le code de vérification
Future<ApiResponse> resendVerifyCode(String email) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Vérification des champs obligatoires
    if (email.isEmpty) {
      apiResponse.success = false;
      apiResponse.message = 'L\'email est obligatoire';
      apiResponse.errors = {'email': 'L\'email est obligatoire'};
      return apiResponse;
    }

    // Créer un objet Map simple pour l'envoi
    Map<String, String> requestData = {
      'email': email,
    };

    final response = await http.post(
      Uri.parse(ApiRoutes.resendVerifyCodeURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final responseData = jsonDecode(response.body);
    apiResponse.success = responseData['success'] ?? false;
    apiResponse.message = responseData['message'] ?? 'Une erreur est survenue';

    if (response.statusCode != 200) {
      apiResponse.errors = responseData['errors'];
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion: ${e.toString()}';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}
