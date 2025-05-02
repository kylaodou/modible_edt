// lib/models/EnseignantModel.dart
class EnseignantModel {
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
  String? specialite;
  String? grade;
  DateTime? createdAt;

  EnseignantModel({
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
    this.specialite,
    this.grade,
    this.createdAt,
  });

  factory EnseignantModel.fromJson(Map<String, dynamic> json) {
    return EnseignantModel(
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
      specialite: json['specialite'],
      grade: json['grade'],
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
      'specialite': specialite,
      'grade': grade,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
