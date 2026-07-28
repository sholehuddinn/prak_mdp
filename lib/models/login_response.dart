import 'user_model.dart';
class LoginResponse {
  final String status;
  final String message;
  final String? token;
  final UserModel? user;
  LoginResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });
// Melakukan parsing data respons login dari JSON Map
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      token: json['token'],
      user: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }
}