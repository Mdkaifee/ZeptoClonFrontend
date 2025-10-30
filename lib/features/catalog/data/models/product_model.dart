import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.quantityValue,
    this.quantityUnit,
    this.category,
  });

  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? quantityValue;
  final String? quantityUnit;
  final String? category;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as Map<String, dynamic>?;
    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString(),
      imageUrl: json['image']?.toString() ?? json['imgUrl']?.toString(),
      quantityValue: quantity?['value']?.toString(),
      quantityUnit: quantity?['unit']?.toString(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (quantityValue != null || quantityUnit != null)
        'quantity': <String, dynamic>{
          if (quantityValue != null) 'value': quantityValue,
          if (quantityUnit != null) 'unit': quantityUnit,
        },
      if (category != null) 'category': category,
    };
  }

  String get formattedQuantity {
    if ((quantityValue ?? '').isEmpty) {
      return '';
    }
    if ((quantityUnit ?? '').isEmpty) {
      return quantityValue ?? '';
    }
    return '$quantityValue $quantityUnit';
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? quantityValue,
    String? quantityUnit,
    String? category,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      quantityValue: quantityValue ?? this.quantityValue,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      category: category ?? this.category,
    );
  }

  static const empty = ProductModel(id: '', name: '', price: 0);

  bool get isEmpty => this == ProductModel.empty;

  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props =>
      [id, name, price, description, imageUrl, quantityValue, quantityUnit, category];
}
