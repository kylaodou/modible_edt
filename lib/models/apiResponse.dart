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

  /// Factory method to create an ApiResponse from a JSON map
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      errors: json['errors'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }
}