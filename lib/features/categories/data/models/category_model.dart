import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.name,
    required this.productCount,
  });

  final String name;
  final int productCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: (json['name'] ?? '').toString(),
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, productCount];
}
