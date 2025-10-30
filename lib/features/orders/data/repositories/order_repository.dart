import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/orders/data/models/order_model.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  OrderRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<OrderModel>> fetchOrders(String userId) async {
    final response = await _apiService.get('/api/orders/user/$userId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(OrderModel.fromJson)
            .toList();
      }
      return const <OrderModel>[];
    }

    if (response.statusCode == 404) {
      // Treat "not found" as empty orders list to avoid surfacing an error.
      return const <OrderModel>[];
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to fetch orders',
      statusCode: response.statusCode,
    );
  }

  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double totalAmount,
    required String paymentStatus,
    required String orderStatus,
  }) async {
    final response = await _apiService.post(
      '/api/orders',
      headers: _jsonHeaders,
      body: jsonEncode({
        'userId': userId,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentStatus': paymentStatus,
        'orderStatus': orderStatus,
      }),
    );

    final decoded = _decode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic>? orderJson;

      if (decoded is Map<String, dynamic>) {
        if (decoded['order'] is Map<String, dynamic>) {
          orderJson = decoded['order'] as Map<String, dynamic>;
        } else if (decoded['data'] is Map<String, dynamic>) {
          orderJson = decoded['data'] as Map<String, dynamic>;
        } else if (decoded.containsKey('cartItems')) {
          orderJson = decoded;
        }
      }

      OrderModel? parsedOrder;
      if (orderJson != null) {
        try {
          parsedOrder = OrderModel.fromJson(orderJson);
        } catch (_) {
          parsedOrder = null;
        }
      }

      if (parsedOrder != null) {
        return parsedOrder;
      }

      final fallbackId = orderJson?['_id']?.toString() ??
          orderJson?['id']?.toString() ??
          decoded?['orderId']?.toString() ??
          '';

      return OrderModel(
        id: fallbackId,
        items: cartItems,
        totalAmount: totalAmount,
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
        createdAt: DateTime.now(),
      );
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to create order',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _jsonHeaders =>
      const {'Content-Type': 'application/json', 'Accept': 'application/json'};

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

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return null;
  }
}
