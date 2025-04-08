class ApiResponse {
  bool success;
  String? message;
  dynamic data;
  dynamic errors;
  String? status;


  ApiResponse({
    this.success = false,
    this.message,
    this.data,
    this.errors,
    this.status,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }
}