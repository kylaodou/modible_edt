class LoginModel {
  //Les champs du login qui sont pareil que dans mon api
  String? id;
  String email;
  String password;
  String? actif;
  String? verificationCode;
  bool verified;
  DateTime? codeExpiryDate;

  String? socialProvider;
  String? socialUid;
  String? firebaseUid;
  DateTime? createdAt;

  //Constructeur
// Constructeur avec paramètres nommés
  LoginModel({
    this.id,
    required this.email,
    required this.password,
    this.actif,
    this.verificationCode,
    this.verified = false,
    this.codeExpiryDate,
    this.socialProvider,
    this.socialUid,
    this.firebaseUid,
    this.createdAt,
  });

  // Convertir un JSON en objet login, ce qu'il reçoit en LoginModel
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['data']['id'],
      email: json['data']['email'],
      password: json['data']['password'],
      actif: json['data']['actif'],
      verificationCode: json['data']['verificationCode'],
      verified: json['data']['verified'] ?? false,
      codeExpiryDate: json['codeExpiryDate'] != null
          ? DateTime.parse(json['codeExpiryDate'])
          : null,
      socialProvider: json['data']['socialProvider'],
      socialUid: json['data']['socialUid'],
      firebaseUid: json['data']['firebaseUid'],
      createdAt: json['data']['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
  // Convertir LoginModel en JSON pour envoyer à l'API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (id != null) 'id': id,
      if (actif != null) 'actif': actif,
      if (verificationCode != null) 'verificationCode': verificationCode,
      'verified': verified,
      if (codeExpiryDate != null) 'codeExpiryDate': codeExpiryDate!.toIso8601String(),
      if (socialProvider != null) 'socialProvider': socialProvider,
      if (socialUid != null) 'socialUid': socialUid,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  //Information pour le log
  @override
  String toString() {
    return 'LoginModel(id: $id, email: $email, password: $password, actif: $actif, verificationCode: $verificationCode, verified: $verified, codeExpiryDate: $codeExpiryDate, socialProvider: $socialProvider, socialUid: $socialUid, firebaseUid: $firebaseUid, createdAt: $createdAt)';
  }
}
