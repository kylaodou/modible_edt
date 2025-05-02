// lib/models/DisponibiliteModel.dart
class DisponibiliteModel {
  String? id;
  String? jour;
  String? creneauId;
  String? enseignantId;
  bool? disponible;
  String? commentaire;
  DateTime? debutSemaine;
  DateTime? finSemaine;
  DateTime? createdAt;

  DisponibiliteModel({
    this.id,
    this.jour,
    this.creneauId,
    this.enseignantId,
    this.disponible,
    this.commentaire,
    this.debutSemaine,
    this.finSemaine,
    this.createdAt,
  });

  factory DisponibiliteModel.fromJson(Map<String, dynamic> json) {
    return DisponibiliteModel(
      id: json['id'],
      jour: json['jour'],
      creneauId: json['creneauId'],
      enseignantId: json['enseignantId'],
      disponible: json['disponible'],
      commentaire: json['commentaire'],
      debutSemaine: json['debutSemaine'] != null
          ? DateTime.parse(json['debutSemaine'])
          : null,
      finSemaine: json['finSemaine'] != null
          ? DateTime.parse(json['finSemaine'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jour': jour,
      'creneauId': creneauId,
      'enseignantId': enseignantId,
      'disponible': disponible,
      'commentaire': commentaire,
      'debutSemaine': debutSemaine?.toIso8601String(),
      'finSemaine': finSemaine?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
