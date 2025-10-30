import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';

class CartItemModel extends Equatable {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.productAmount,
  });

  final String id;
  final ProductModel product;
  final int quantity;
  final double productAmount;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = ProductModel.fromJson(json['product'] as Map<String, dynamic>);
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
    final amountValue = json['productAmount'] ?? json['totalAmount'];
    final productAmount = (amountValue is num)
        ? amountValue.toDouble()
        : double.tryParse(amountValue?.toString() ?? '');

    return CartItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: product,
      quantity: quantity,
      productAmount: productAmount ?? (product.price * quantity),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'productAmount': productAmount,
    };
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    double? productAmount,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      productAmount: productAmount ?? this.productAmount,
    );
  }

  double get totalPrice => productAmount;

  double get unitPrice {
    if (quantity <= 0) return product.price;
    return productAmount / quantity;
  }

  @override
  List<Object?> get props => [id, product, quantity, productAmount];
}
