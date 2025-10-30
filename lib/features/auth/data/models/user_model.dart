import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
  });

  final String id;
  final String name;
  final String email;
  final String? mobile;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      mobile: json['mobile']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      if (mobile != null) 'mobile': mobile,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
    );
  }

  static const empty = UserModel(id: '', name: '', email: '');

  bool get isEmpty => this == UserModel.empty;

  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, name, email, mobile];
}
