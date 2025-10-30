import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';

class CartItemModel extends Equatable {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final ProductModel product;
  final int quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [id, product, quantity];
}
