import 'package:equatable/equatable.dart';

class ContentPageModel extends Equatable {
  const ContentPageModel({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? updatedAt;

  factory ContentPageModel.fromJson(Map<String, dynamic> json) {
    final updatedAtRaw = json['updatedAt']?.toString();
    return ContentPageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      updatedAt: updatedAtRaw == null || updatedAtRaw.isEmpty
          ? null
          : DateTime.tryParse(updatedAtRaw),
    );
  }

  @override
  List<Object?> get props => [id, title, body, updatedAt];
}
