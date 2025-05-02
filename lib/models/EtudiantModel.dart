// lib/models/etudiantModel.dart
class EtudiantModel {
  String? id;
  String? matricule;
  String? nom;
  String? prenom;
  DateTime? dateNaissance;
  String? lieuNaissance;
  String? email;
  String? telephone;
  String? sexe;
  String? userId;
  String? classeId;
  bool? estDelegue;
  List<String>? parentsIds;
  DateTime? createdAt;

  EtudiantModel({
    this.id,
    this.matricule,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.lieuNaissance,
    this.email,
    this.telephone,
    this.sexe,
    this.userId,
    this.classeId,
    this.estDelegue,
    this.parentsIds,
    this.createdAt,
  });

  factory EtudiantModel.fromJson(Map<String, dynamic> json) {
    return EtudiantModel(
      id: json['id'],
      matricule: json['matricule'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.parse(json['dateNaissance'])
          : null,
      lieuNaissance: json['lieuNaissance'],
      email: json['email'],
      telephone: json['telephone'],
      sexe: json['sexe'],
      userId: json['userId'],
      classeId: json['classeId'],
      estDelegue: json['estDelegue'],
      parentsIds: json['parentsIds'] != null
          ? List<String>.from(json['parentsIds'])
          : null,
      createdAt:
      json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance?.toIso8601String(),
      'lieuNaissance': lieuNaissance,
      'email': email,
      'telephone': telephone,
      'sexe': sexe,
      'userId': userId,
      'classeId': classeId,
      'estDelegue': estDelegue,
      'parentsIds': parentsIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}