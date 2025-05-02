class ApiRoutes {
  static const baseURL = "http://localhost:8080/api";
  static const baseUrl = "http://localhost:8080";

  // Routes d'authentification et gestion utilisateur
  static const inscriptionURL = '$baseURL/users/register';
  static const verifyCodeURL = '$baseURL/users/verify';
  static const resendVerifyCodeURL = '$baseURL/users/resend-code';
  static const connexionEmailPasswordURL = '$baseURL/users/login';
  static const inactiveUsersURL = '$baseURL/users/inactive';
  static const String connexionGoogleURL = '$baseURL/users/login/google';
  static const String connexionFacebookURL = '$baseURL/users/login/facebook';
  static String getUserDetailsURL(String email) {
    return '$baseURL/users/userDetails?email=$email';
  }
  // Méthodes pour construire des URLs avec paramètres
  static String checkUserStatus(String email) =>
      '$baseURL/users/status?email=$email';
  
  static String getUserById(String id) => '$baseURL/users/$id';
  static String getUserByEmail(String email) => '$baseURL/users/email/$email';
  static String updateUser(String id) => '$baseURL/users/$id';
  static String updateUserPhoto(String id) => '$baseURL/users/$id/photo';
  static String validateUser(String id) => '$baseURL/users/validate/$id';
  static String invalidateUser(String id) => '$baseURL/users/invalidate/$id';
  static String deleteUser(String id) => '$baseURL/users/$id';
  
  // Routes pour l'emploi du temps
  static const getScheduleURL = '$baseURL/schedule';
  static String getScheduleByUserId(String userId) => '$baseURL/schedule/user/$userId';
}
