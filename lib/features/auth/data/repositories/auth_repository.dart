import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/services/local_storage_service.dart';
import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  AuthRepository({
    required ApiService apiService,
    LocalStorageService? storage,
  })  : _apiService = apiService,
        _storage = storage ?? LocalStorageService.instance;

  final ApiService _apiService;
  final LocalStorageService _storage;

  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyToken = 'userToken';
  static const _keyUser = 'userData';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/api/auth/login',
      headers: _defaultHeaders,
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
      }),
    );

    final decoded = _decodeResponse(response);
    if (response.statusCode == 200) {
      final user = UserModel.fromJson(decoded['user'] as Map<String, dynamic>);
      final token = decoded['token'] as String? ?? '';
      await _persistAuthData(user, token);
      return AuthResult(user: user, token: token);
    }
    throw AuthException(
      message: decoded['message']?.toString() ?? 'Failed to login',
      statusCode: response.statusCode,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/api/auth/signup',
      headers: _defaultHeaders,
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Registration succeeded; nothing else to do here.
      return;
    }

    final decoded = _decodeResponse(response);
    throw AuthException(
      message: decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          'Registration failed',
      statusCode: response.statusCode,
    );
  }

  Future<void> logout() async {
    await _storage.remove(_keyIsLoggedIn);
    await _storage.remove(_keyToken);
    await _storage.remove(_keyUser);
  }

  Future<bool> isLoggedIn() async {
    return await _storage.readBool(_keyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getStoredUser() async {
    final json = await _storage.readJson(_keyUser);
    if (json == null) {
      return null;
    }
    return UserModel.fromJson(json);
  }

  Future<String?> getStoredToken() async {
    return _storage.readString(_keyToken);
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String mobile,
  }) async {
    final response = await _apiService.patch(
      '/api/user/edit/$userId',
      headers: _defaultHeaders,
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'mobile': mobile,
      }),
    );

    if (response.statusCode == 200) {
      final existingUser = await getStoredUser();
      final updatedUser = (existingUser ?? UserModel.empty).copyWith(
        name: name,
        mobile: mobile,
      );
      await _storage.saveJson(_keyUser, updatedUser.toJson());
      return updatedUser;
    }

    final decoded = _decodeResponse(response);
    throw AuthException(
      message: decoded['message']?.toString() ?? 'Failed to update profile',
      statusCode: response.statusCode,
    );
  }

  Future<void> _persistAuthData(UserModel user, String token) async {
    await _storage.saveBool(_keyIsLoggedIn, true);
    await _storage.saveString(_keyToken, token);
    await _storage.saveJson(_keyUser, user.toJson());
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Map<String, String> get _defaultHeaders =>
      const {'Content-Type': 'application/json', 'Accept': 'application/json'};
}

class AuthResult {
  const AuthResult({
    required this.user,
    required this.token,
  });

  final UserModel user;
  final String token;
}

class AuthException implements Exception {
  AuthException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException(statusCode: $statusCode, message: $message)';
}
