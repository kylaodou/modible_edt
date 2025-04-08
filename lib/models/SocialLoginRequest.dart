class SocialLoginRequest {
  final String email;
  final String? idToken;
  final String provider;  // "google" ou "facebook"
  final String uid;       // ID utilisateur du provider

  SocialLoginRequest({
    required this.email,
    this.idToken,
    required this.provider,
    required this.uid
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'idToken': idToken,
      'provider': provider,
      'uid': uid,
    };
  }

  factory SocialLoginRequest.fromJson(Map<String, dynamic> json) {
    return SocialLoginRequest(
      email: json['email'],
      idToken: json['idToken'],
      provider: json['provider'],
      uid: json['uid'],
    );
  }
}