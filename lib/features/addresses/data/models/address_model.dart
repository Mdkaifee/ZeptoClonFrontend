import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  const AddressModel({
    required this.id,
    required this.buildingName,
    required this.area,
    required this.city,
    required this.pincode,
    required this.state,
    required this.label,
    this.landmark,
    this.receiverName,
    this.phone,
  });

  final String id;
  final String buildingName;
  final String area;
  final String city;
  final String pincode;
  final String state;
  final String label;
  final String? landmark;
  final String? receiverName;
  final String? phone;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      buildingName: (json['buildingName'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      landmark: json['landmark']?.toString(),
      receiverName: json['receiverName']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'buildingName': buildingName,
      'area': area,
      'city': city,
      'pincode': pincode,
      'state': state,
      'label': label,
      if (landmark != null) 'landmark': landmark,
      if (receiverName != null) 'receiverName': receiverName,
      if (phone != null) 'phone': phone,
    };
  }

  AddressModel copyWith({
    String? id,
    String? buildingName,
    String? area,
    String? city,
    String? pincode,
    String? state,
    String? label,
    String? landmark,
    String? receiverName,
    String? phone,
  }) {
    return AddressModel(
      id: id ?? this.id,
      buildingName: buildingName ?? this.buildingName,
      area: area ?? this.area,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      label: label ?? this.label,
      landmark: landmark ?? this.landmark,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
    );
  }

  static const empty = AddressModel(
    id: '',
    buildingName: '',
    area: '',
    city: '',
    pincode: '',
    state: '',
    label: '',
  );

  bool get isEmpty => this == AddressModel.empty;

  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        id,
        buildingName,
        area,
        city,
        pincode,
        state,
        label,
        landmark,
        receiverName,
        phone,
      ];
}
