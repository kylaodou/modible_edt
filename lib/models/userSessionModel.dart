// lib/models/userSessionModel.dart
import 'package:modible_edt/models/userModel.dart';
import 'package:modible_edt/models/etudiantModel.dart';
import 'package:modible_edt/models/EnseignantModel.dart';
// Importez d'autres modèles de détails si nécessaire (enseignant, admin, etc.)

class UserSessionModel {
  UserModel user;
  dynamic details; // Peut être EtudiantModel ou autre selon le rôle
  String? id;
  String? userId;
  String? displayName;

  UserSessionModel({
    required this.user,
    this.details,
    this.id,
    this.userId,
    this.displayName,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    // Créer l'utilisateur de base
    UserModel user = UserModel.fromJson(json['user']);

    // Créer l'objet détails en fonction du rôle
    dynamic details;
    if (json['details'] != null) {
      switch (user.role) {
        case 'ETUDIANT':
          details = EtudiantModel.fromJson(json['details']);
          break;
        case 'ENSEIGNANT':
          details = EnseignantModel.fromJson(json['details']);
          break;
        default:
          details = json['details']; // Garder comme map si pas de modèle spécifique
      }
    }

    // Déterminer le displayName en fonction du rôle
    String? displayName;
    String? id;
    String? userId;

    if (details != null) {
      if (user.role == 'ETUDIANT' || user.role == 'ENSEIGNANT') {
        displayName = '${details.prenom} ${details.nom}';
        id = details.id;
        userId = details.userId;
      }
    }

    return UserSessionModel(
      user: user,
      details: details,
      displayName: displayName,
      id: id,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'user': user.toJson(),
      'id': id,
      'userId': userId,
      'displayName': displayName,
    };

    if (details != null) {
      if (details is EtudiantModel) {
        result['details'] = (details as EtudiantModel).toJson();
      } else if (details is EnseignantModel) {
        result['details'] = (details as EnseignantModel).toJson();
      } else if (details is Map) {
        result['details'] = details;
      }
    }

    return result;
  }

  // Méthodes utilitaires
  String get nomComplet {
    if (details is EtudiantModel) {
      EtudiantModel etudiant = details as EtudiantModel;
      return '${etudiant.prenom ?? ''} ${etudiant.nom ?? ''}';
    } else if (details is EnseignantModel) {
      EnseignantModel enseignant = details as EnseignantModel;
      return '${enseignant.prenom ?? ''} ${enseignant.nom ?? ''}';
    } else if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return user.email ?? '';
  }
}