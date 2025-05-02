import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/models/userModel.dart';
import 'package:modible_edt/utils/roles.dart';
import 'package:http/http.dart' as http;
import 'package:modible_edt/services/userSessionService.dart';

import '../core/routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserSessionService _userSessionService = UserSessionService();

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _userSessionService.getUserData();
  }

  // Méthode pour standardiser la structure de session utilisateur
  Map<String, dynamic> _standardizeUserSession(Map<String, dynamic> apiData, {String? uid, String? photoURL, String? email}) {
    print('[DEBUG] Données brutes de l\'API pour _standardizeUserSession:');
    print(apiData);

    // Extraire le rôle depuis la structure de l'API
    final role = apiData['data']?['user']?['role'] ?? Roles.ETUDIANT;
    print('[DEBUG] Rôle détecté: $role');

    // Structure compatible avec le nouveau format
    Map<String, dynamic> sessionData = {
      'data': {
        'user': {
          'email': email ?? apiData['data']?['user']?['email'],
          'uid': uid ?? apiData['data']?['user']?['id'],
          'photoURL': photoURL ?? apiData['data']?['user']?['photo'],
          'role': role,
          'verified': apiData['data']?['user']?['verified'] ?? true,
          'actif': apiData['data']?['user']?['actif'] ?? true,
        },
        'details': apiData['data']?['details']
      },
      'success': true,
      'message': 'Connexion réussie'
    };

    print('[DEBUG] Session standardisée:');
    print(sessionData);

    return sessionData;
  }
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

      // Récupérer les détails complets de l'utilisateur depuis l'API
      try {
        final response = await http.get(
          Uri.parse(ApiRoutes.getUserDetailsURL(email)),
          headers: {'Content-Type': 'application/json'},
        );

        print('[DEBUG] Réponse API pour getUserDetails:');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          // Log des données utilisateur complètes
          print('[DEBUG] Données utilisateur complètes de l\'API:');
          print(data);

          // Sauvegarder la session avec la structure complète
          await _userSessionService.saveUserSession(data);

          // Standardiser les données avec les informations Firebase
          final standardizedData = _standardizeUserSession(
            data,
            uid: userCredential.user?.uid,
            photoURL: userCredential.user?.photoURL,
            email: email,
          );

          return ApiResponse(
            success: true,
            message: 'Connexion réussie',
            data: standardizedData['data'],
          );
        } else {
          print('[WARNING] Réponse API non valide, utilisation du mode hors ligne');
          // Utiliser les données de base si le serveur ne répond pas correctement
          Map<String, dynamic> userData = {
            'email': email,
            'uid': userCredential.user?.uid,
            'photoURL': userCredential.user?.photoURL,
            'role': Roles.ETUDIANT, // Rôle par défaut
            'verified': true,
            'actif': true,
          };

          // Standardiser la structure des données
          Map<String, dynamic> sessionData = _standardizeUserSession(userData);

          await _userSessionService.saveUserSession(sessionData);

          return ApiResponse(
            success: true,
            message: 'Connexion réussie (mode hors ligne)',
            data: sessionData['data'],
          );
        }
      } catch (e) {
        print('[ERROR] Erreur lors de la récupération des détails utilisateur: $e');
        // En cas d'erreur de connexion à l'API, utiliser uniquement les données Firebase
        Map<String, dynamic> userData = {
          'email': email,
          'uid': userCredential.user?.uid,
          'photoURL': userCredential.user?.photoURL,
          'role': Roles.ETUDIANT, // Rôle par défaut
          'verified': true,
          'actif': true,
        };

        // Standardiser la structure des données
        Map<String, dynamic> sessionData = _standardizeUserSession(userData);

        await _userSessionService.saveUserSession(sessionData);

        return ApiResponse(
          success: true,
          message: 'Connexion réussie (mode hors ligne)',
          data: sessionData['data'],
        );
      }
    } on FirebaseAuthException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur d\'authentification Firebase: ${e.message}',
        errors: {'error': e.code},
      );
    } catch (e) {
      print('[ERROR] Erreur lors de la récupération des détails utilisateur: $e');
      return ApiResponse(
        success: false,
        message: 'Erreur lors de la connexion avec Google: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> signInWithFacebook() async {
    try {
      // Déconnexion de Facebook d'abord pour forcer une nouvelle sélection de compte
      await FacebookAuth.instance.logOut();

      // Déclencher le flux d'authentification Facebook
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.dialogOnly,
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

      // Vérifier le statut du compte dans votre base de données
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

      // Récupérer les détails complets de l'utilisateur depuis l'API
      try {
        final response = await http.get(
          Uri.parse(ApiRoutes.getUserDetailsURL(email)),
          headers: {'Content-Type': 'application/json'},
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          // Ajouter les informations Firebase à l'utilisateur
          if (data['data'] != null && data['data']['user'] != null) {
            data['data']['user']['uid'] = userCredential.user?.uid;
            data['data']['user']['photoURL'] = userCredential.user?.photoURL ?? userData['picture']['data']['url'];
          }

          // Sauvegarder la session avec la structure complète
          await _userSessionService.saveUserSession(data);

          return ApiResponse(
            success: true,
            message: 'Connexion réussie',
            data: data['data'],
          );
        } else {
          // Utiliser les données de base si le serveur ne répond pas correctement
          Map<String, dynamic> fbUserData = {
            'email': email,
            'uid': userCredential.user?.uid,
            'photoURL': userCredential.user?.photoURL ?? userData['picture']['data']['url'],
            'role': Roles.ETUDIANT, // Rôle par défaut
            'verified': true,
            'actif': true,
          };

          // Standardiser la structure des données
          Map<String, dynamic> sessionData = _standardizeUserSession(fbUserData);

          await _userSessionService.saveUserSession(sessionData);

          return ApiResponse(
            success: true,
            message: 'Connexion réussie (mode hors ligne)',
            data: sessionData['data'],
          );
        }
      } catch (e) {
        // En cas d'erreur de connexion à l'API, utiliser uniquement les données Firebase
        Map<String, dynamic> fbUserData = {
          'email': email,
          'uid': userCredential.user?.uid,
          'photoURL': userCredential.user?.photoURL ?? userData['picture']['data']['url'],
          'role': Roles.ETUDIANT, // Rôle par défaut
          'verified': true,
          'actif': true,
        };

        // Standardiser la structure des données
        Map<String, dynamic> sessionData = _standardizeUserSession(fbUserData);

        await _userSessionService.saveUserSession(sessionData);

        return ApiResponse(
          success: true,
          message: 'Connexion réussie (mode hors ligne)',
          data: sessionData['data'],
        );
      }
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

  Future<ApiResponse> checkUserStatus(String email) async {
    try {
      // Appel à votre API Spring pour vérifier le statut de l'utilisateur
      final response = await http.get(
        Uri.parse(ApiRoutes.checkUserStatus(email)),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'],
          data: data['data'],
          status: data['status'],
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Compte non trouvé. Veuillez vous inscrire d\'abord.',
          status: 'NOT_FOUND',
        );
      } else if (response.statusCode == 403) {
        return ApiResponse(
          success: false,
          message: data['message'],
          status: data['status'],
        );
      } else {
        return ApiResponse(
          success: false,
          message:
          data['message'] ?? 'Erreur lors de la vérification du compte',
          status: data['status'],
        );
      }
    } catch (e) {
      print("Erreur lors de la vérification du statut: ${e.toString()}");
      // En cas d'erreur de connexion, retourner une réponse qui permettra quand même de continuer
      return ApiResponse(
        success: true,
        message: 'Connexion à l\'API impossible, mode hors ligne activé',
        data: {
          'email': email,
          'role': Roles.ETUDIANT, // Rôle par défaut
          'verified': true,
          'actif': true,
        },
        status: 'ACTIVE',
      );
    }
  }

  // Méthode pour se déconnecter
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
    await _userSessionService.clearUserSession();
  }

  // Méthode de connexion avec email et mot de passe
  Future<ApiResponse> signInWithEmailPassword(String email, String password) async {
    try {
      // Vérifier le statut du compte dans votre base de données
      final ApiResponse statusResponse = await checkUserStatus(email);

      // Si le compte n'existe pas ou n'est pas dans un état valide
      if (!statusResponse.success) {
        return statusResponse;
      }

      // Si nous arrivons ici, le compte est valide - continuer avec l'authentification Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer les détails complets de l'utilisateur depuis l'API
      try {
        final response = await http.get(
          Uri.parse(ApiRoutes.getUserDetailsURL(email)),
          headers: {'Content-Type': 'application/json'},
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          // Ajouter les informations Firebase à l'utilisateur
          if (data['data'] != null && data['data']['user'] != null) {
            data['data']['user']['uid'] = userCredential.user?.uid;
            data['data']['user']['photoURL'] = userCredential.user?.photoURL;
          }

          // Sauvegarder la session avec la structure complète
          await _userSessionService.saveUserSession(data);

          return ApiResponse(
            success: true,
            message: 'Connexion réussie',
            data: data['data'],
          );
        } else {
          // Utiliser les données de base si le serveur ne répond pas correctement
          Map<String, dynamic> userData = {
            'email': email,
            'uid': userCredential.user?.uid,
            'photoURL': userCredential.user?.photoURL,
            'role': Roles.ETUDIANT, // Rôle par défaut
            'verified': true,
            'actif': true,
          };

          // Standard iser la structure des données
          Map<String, dynamic> sessionData = _standardizeUserSession(userData);

          await _userSessionService.saveUserSession(sessionData);

          return ApiResponse(
            success: true,
            message: 'Connexion réussie (mode hors ligne)',
            data: sessionData['data'],
          );
        }
      } catch (e) {
        // En cas d'erreur de connexion à l'API, utiliser uniquement les données Firebase
        Map<String, dynamic> userData = {
          'email': email,
          'uid': userCredential.user?.uid,
          'photoURL': userCredential.user?.photoURL,
          'role': Roles.ETUDIANT, // Rôle par défaut
          'verified': true,
          'actif': true,
        };

        // Standardiser la structure des données
        Map<String, dynamic> sessionData = _standardizeUserSession(userData);

        await _userSessionService.saveUserSession(sessionData);

        return ApiResponse(
          success: true,
          message: 'Connexion réussie (mode hors ligne)',
          data: sessionData['data'],
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé pour cet email.';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect.';
          break;
        case 'invalid-email':
          message = 'Format d\'email invalide.';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé.';
          break;
        default:
          message = 'Erreur d\'authentification: ${e.message}';
      }
      
      return ApiResponse(
        success: false,
        message: message,
        errors: {'error': e.code},
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur lors de la connexion: ${e.toString()}',
      );
    }
  }
}