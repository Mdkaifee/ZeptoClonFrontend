import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/addresses/data/models/address_model.dart';
import 'package:http/http.dart' as http;

class AddressRepository {
  AddressRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<AddressModel>> fetchAddresses(String userId) async {
    final response = await _apiService.get('/api/addresses/$userId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AddressModel.fromJson)
            .toList();
      }
      return const <AddressModel>[];
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to load addresses',
      statusCode: response.statusCode,
    );
  }

  Future<List<AddressModel>> addAddress({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiService.post(
      '/api/addresses',
      headers: _jsonHeaders,
      body: jsonEncode({
        'userId': userId,
        ...payload,
      }),
    );
    final decoded = _decode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final addresses = decoded is Map<String, dynamic>
          ? decoded['addresses']
          : null;
      return _parseAddressList(addresses);
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to add address',
      statusCode: response.statusCode,
    );
  }

  Future<AddressModel> updateAddress({
    required String userId,
    required String addressId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiService.patch(
      '/api/addresses/$userId/$addressId',
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic> &&
          decoded['address'] is Map<String, dynamic>) {
        return AddressModel.fromJson(
          decoded['address'] as Map<String, dynamic>,
        );
      }
      throw AppException(
        'Unexpected response format for update',
        statusCode: response.statusCode,
      );
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to update address',
      statusCode: response.statusCode,
    );
  }

  Future<List<AddressModel>> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    final response =
        await _apiService.delete('/api/addresses/$userId/$addressId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      final addresses = decoded is Map<String, dynamic>
          ? decoded['addresses']
          : null;
      return _parseAddressList(addresses);
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to delete address',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  List<AddressModel> _parseAddressList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AddressModel.fromJson)
          .toList();
    }
    return const <AddressModel>[];
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return null;
  }
}
