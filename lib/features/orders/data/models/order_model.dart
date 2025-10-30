import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  final String id;
  final List<CartItemModel> items;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['cartItems'] as List<dynamic>? ?? const [];
    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: itemsJson
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'cartItems': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    double? totalAmount,
    String? paymentStatus,
    String? orderStatus,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, items, totalAmount, paymentStatus, orderStatus, createdAt];
}
