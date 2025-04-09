class ApiRoutes {
  static const baseURL = "http://localhost:8080/api";
  static const inscriptionURL = '$baseURL/login';
  static const verifyCodeURL = '$baseURL/login/verify';
  static const resendVerifyCodeURL = '$baseURL/login/resend-code';
  static const checkUserStatusURL = '$baseURL/login/status';
  static const connexionEmailPasswordURL = '$baseURL/login/authenticate';

  static String checkUserStatus(String email) =>
      '$baseURL/login/status?email=$email';
}
