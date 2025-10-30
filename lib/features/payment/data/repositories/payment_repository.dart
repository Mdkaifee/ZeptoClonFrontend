import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  PaymentRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<String> createRazorpayOrder({
    required double amount,
    required String userId,
  }) async {
    final response = await _apiService.post(
      '/api/payment/create-order',
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amount * 100).toInt(),
        'userId': userId,
      }),
    );

    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is Map && decoded['orderId'] != null) {
        return decoded['orderId'].toString();
      }
      throw AppException('Invalid response for Razorpay order creation');
    }

    throw AppException(
      (decoded is Map && decoded['message'] != null)
          ? decoded['message'].toString()
          : 'Failed to create payment order',
      statusCode: response.statusCode,
    );
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }
}
