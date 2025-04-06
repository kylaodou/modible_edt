class ApiResponse {
  bool success;
  String? message;
  dynamic data;
  dynamic errors;

  ApiResponse({
    this.success = false,
    this.message,
    this.data,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }
}