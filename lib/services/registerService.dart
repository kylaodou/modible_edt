import 'dart:convert';

import 'package:modible_edt/core/constants.dart';
import 'package:modible_edt/models/loginModel.dart';
import 'package:http/http.dart' as http;

import '../core/routes.dart';
import '../models/apiResponse.dart';

Future<ApiResponse> inscription(LoginModel login) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(inscriptionURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(login.toJson()),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        final responseData = jsonDecode(response.body);
        apiResponse.data = LoginModel.fromJson(responseData);
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Inscription réussie';
        break;
      case 400:
      case 409:
      case 500:
        final responseData = jsonDecode(response.body);
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de l\'inscription';
        apiResponse.errors = responseData['errors'];
        break;
      default:
        apiResponse.success = false;
        apiResponse.message = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}

Future<ApiResponse> verifyCode(String email, String code) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(verifyCodeURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        final responseData = jsonDecode(response.body);
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Votre compte a été vérifié avec succès';

        // Récupération des données spécifiques à la vérification
        if (responseData['login'] != null) {
          apiResponse.data = LoginModel.fromJson(responseData['login']);
        }

        break;
      case 400:
      case 409:
      case 500:
        final responseData = jsonDecode(response.body);
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur';
        apiResponse.errors = responseData['errors'];
        break;
      default:
        apiResponse.success = false;
        apiResponse.message = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}

Future<ApiResponse> resendVerifyCode(String email) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(resendVerifyCodeURL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        final responseData = jsonDecode(response.body);
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Votre compte a été vérifié avec succès';

        // Récupération des données spécifiques à la vérification
        if (responseData['login'] != null) {
          apiResponse.data = LoginModel.fromJson(responseData['login']);
        }

        break;
      case 400:
      case 409:
      case 500:
        final responseData = jsonDecode(response.body);
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur';
        apiResponse.errors = responseData['errors'];
        break;
      default:
        apiResponse.success = false;
        apiResponse.message = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception: $e');
    apiResponse.success = false;
    apiResponse.message = 'Erreur de connexion';
    apiResponse.errors = e.toString();
  }
  return apiResponse;
}