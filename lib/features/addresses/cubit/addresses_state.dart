import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/addresses/data/models/address_model.dart';

enum AddressesStatus { initial, loading, success, failure }

const _sentinel = Object();

class AddressesState extends Equatable {
  const AddressesState({
    this.status = AddressesStatus.initial,
    this.addresses = const <AddressModel>[],
    this.errorMessage,
    this.infoMessage,
    this.isMutating = false,
    this.pendingAddressId,
  });

  final AddressesStatus status;
  final List<AddressModel> addresses;
  final String? errorMessage;
  final String? infoMessage;
  final bool isMutating;
  final String? pendingAddressId;

  AddressesState copyWith({
    AddressesStatus? status,
    List<AddressModel>? addresses,
    String? errorMessage,
    String? infoMessage,
    bool? isMutating,
    Object? pendingAddressId = _sentinel,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
      isMutating: isMutating ?? this.isMutating,
      pendingAddressId: identical(pendingAddressId, _sentinel)
          ? this.pendingAddressId
          : pendingAddressId as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addresses,
        errorMessage,
        infoMessage,
        isMutating,
        pendingAddressId,
      ];
}
