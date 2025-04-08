import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/models/loginModel.dart';
import 'package:http/http.dart' as http;

import '../core/routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Méthode pour l'a connexion avec Google
  Future<ApiResponse> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si l'utilisateur annule la connexion
      if (googleUser == null) {
        return ApiResponse(
          success: false,
          message: 'Connexion Google annulée',
        );
      }

      // Obtenir l'email du compte Google
      final String email = googleUser.email;

      // Vérifier le statut du compte dans votre base de données
      final ApiResponse statusResponse = await checkUserStatus(email);

      // Si le compte n'existe pas ou n'est pas dans un état valide
      if (!statusResponse.success) {
        return statusResponse;
      }

      // Si nous arrivons ici, le compte est valide - continuer avec l'authentification Firebase
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Combiner les données de Firebase avec les données de votre API
      final userData = statusResponse.data;
      userData['uid'] = userCredential.user?.uid;
      userData['photoURL'] = userCredential.user?.photoURL;

      return ApiResponse(
        success: true,
        message: 'Connexion réussie',
        data: userData,
      );
    } on FirebaseAuthException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur d\'authentification Firebase: ${e.message}',
        errors: {'error': e.code},
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur  lors de la connexion avec Google: ${e.toString()}',
      );
    }
  }
  // Nouvelle méthode pour l'inscription avec Facebook
// Méthode pour la connexion avec Facebook
  Future<ApiResponse> signInWithFacebook() async {
    try {
      // Déconnexion de Facebook d'abord pour forcer une nouvelle sélection de compte
      await FacebookAuth.instance.logOut();

      // Déclencher le flux d'authentification Facebook avec des options pour forcer la sélection
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.dialogOnly, // Force l'ouverture d'une boîte de dialogue
      );


      // Vérifier si la connexion a été annulée ou a échoué
      if (loginResult.status != LoginStatus.success) {
        return ApiResponse(
          success: false,
          message: 'Connexion Facebook annulée ou échouée',
        );
      }

      // Obtenir les informations de l'utilisateur Facebook
      final userData = await FacebookAuth.instance.getUserData();

      // Vérifier si l'email est disponible
      final String? email = userData['email'];

      if (email == null) {
        return ApiResponse(
          success: false,
          message: 'L\'email est requis pour la connexion',
        );
      }

      // Vérifier le statut du compte dans votre base de données, comme pour Google
      final ApiResponse statusResponse = await checkUserStatus(email);

      // Si le compte n'existe pas ou n'est pas dans un état valide
      if (!statusResponse.success) {
        return statusResponse;
      }

      // Si nous arrivons ici, le compte est valide - continuer avec l'authentification Firebase
      final AccessToken? accessToken = loginResult.accessToken;

      if (accessToken == null) {
        return ApiResponse(
          success: false,
          message: 'Impossible d\'obtenir le token d\'accès Facebook',
        );
      }

      // Créer les identifiants Firebase avec le token Facebook
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(accessToken.tokenString);

      // Connecter l'utilisateur à Firebase avec les identifiants
      final UserCredential userCredential =
      await _auth.signInWithCredential(facebookAuthCredential);

      // Combiner les données de Firebase avec les données de votre API, comme pour Google
      final userApiData = statusResponse.data;
      userApiData['uid'] = userCredential.user?.uid;
      userApiData['photoURL'] = userCredential.user?.photoURL ?? userData['picture']['data']['url'];

      return ApiResponse(
        success: true,
        message: 'Connexion réussie',
        data: userApiData,
      );
    } on FirebaseAuthException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur d\'authentification Firebase: ${e.message}',
        errors: {'error': e.code},
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur lors de la connexion avec Facebook: ${e.toString()}',
      );
    }
  }

  // Méthode pour se déconnecter (mise à jour pour inclure Facebook)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print("Erreur de déconnexion Google: $e");
    }

    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("Erreur de déconnexion Facebook: $e");
    }

    await _auth.signOut();
  }

  Future<ApiResponse> checkUserStatus(String email) async {
    try {
      // Appel à votre API Spring pour vérifier le statut de l'utilisateur
      final response = await http.get(
        Uri.parse('http://192.168.100.158:8080/api/login/status?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          message: data['message'],
          data: data['data'],
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Compte non trouvé. Veuillez vous inscrire d\'abord.',
          status: 'NOT_FOUND',
        );
      } else {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la vérification du compte',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur de connexion: ${e.toString()}',
      );
    }
  }

  // Méthode pour l'authentification avec email et mot de passe
  Future<ApiResponse> signInWithEmailPassword(String email, String password) async {
    try {
      // Appel à votre API Spring Boot pour l'authentification
      final response = await http.post(
        Uri.parse(connexionEmailPasswordURL),
        headers: {'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Si l'authentification est réussie, connecter l'utilisateur à Firebase
        try {
          // Authentification Firebase avec email et mot de passe
          final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Combiner les données Firebase avec les données de votre API
          final userData = data['userData'] ?? data['user'];
          userData['uid'] = userCredential.user?.uid;
          userData['photoURL'] = userCredential.user?.photoURL;

          return ApiResponse(
            success: true,
            message: 'Connexion réussie',
            data: userData,
          );
        } on FirebaseAuthException catch (e) {
          // Gérer les erreurs spécifiques à Firebase
          String message;
          switch (e.code) {
            case 'user-not-found':
              message = 'Aucun utilisateur trouvé avec cet email';
              break;
            case 'wrong-password':
              message = 'Mot de passe incorrect';
              break;
            case 'invalid-credential':
              message = 'Identifiants invalides';
              break;
            default:
              message = 'Erreur d\'authentification Firebase: ${e.message}';
          }

          return ApiResponse(
            success: false,
            message: message,
            errors: {'error': e.code},
          );
        }
      } else {
        // Si l'authentification a échoué
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de l\'authentification',
          status: data['status'],
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur de connexion: ${e.toString()}',
      );
    }
  }
}