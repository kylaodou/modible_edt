import 'package:modible_edt/utils/roles.dart';

class UserModel {
  String? id;
  String? email;
  String? password;
  bool? actif;
  String? role;
  String? verificationCode;
  bool? verified;
  String? codeExpiryDate;
  String? tokenFCM;
  String? photo;
  String? dateCreation;
  String? uid; // Pour Firebase

  UserModel({
    this.id,
    this.email,
    this.password,
    this.actif,
    this.role,
    this.verificationCode,
    this.verified,
    this.codeExpiryDate,
    this.tokenFCM,
    this.photo,
    this.dateCreation,
    this.uid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      actif: json['actif'],
      role: json['role'],
      verificationCode: json['verificationCode'],
      verified: json['verified'],
      codeExpiryDate: json['codeExpiryDate'],
      tokenFCM: json['tokenFCM'],
      photo: json['photo'],
      dateCreation: json['dateCreation'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'actif': actif,
      'role': role,
      'verificationCode': verificationCode,
      'verified': verified,
      'codeExpiryDate': codeExpiryDate,
      'tokenFCM': tokenFCM,
      'photo': photo,
      'dateCreation': dateCreation,
      'uid': uid,
    };
  }
}
