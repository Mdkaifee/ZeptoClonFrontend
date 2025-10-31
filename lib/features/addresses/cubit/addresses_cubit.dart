import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/addresses/cubit/addresses_state.dart';
import 'package:flutter_application_1/features/addresses/data/repositories/address_repository.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit({required AddressRepository addressRepository})
      : _addressRepository = addressRepository,
        super(const AddressesState());

  final AddressRepository _addressRepository;

  String? _userId;

  Future<void> loadAddresses(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.status == AddressesStatus.success &&
        _userId == userId) {
      return;
    }

    _userId = userId;
    emit(
      state.copyWith(
        status: AddressesStatus.loading,
        errorMessage: null,
        infoMessage: null,
        isMutating: false,
        pendingAddressId: null,
      ),
    );

    try {
      final addresses = await _addressRepository.fetchAddresses(userId);
      emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: addresses,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AddressesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    await loadAddresses(userId, forceRefresh: true);
  }

  Future<void> addAddress({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    _userId = userId;
    emit(
      state.copyWith(
        isMutating: true,
        errorMessage: null,
        infoMessage: null,
        pendingAddressId: null,
      ),
    );

    try {
      final addresses = await _addressRepository.addAddress(
        userId: userId,
        payload: payload,
      );
      emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: addresses,
          isMutating: false,
          infoMessage: 'Address added successfully',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateAddress({
    required String userId,
    required String addressId,
    required Map<String, dynamic> payload,
  }) async {
    _userId = userId;
    emit(
      state.copyWith(
        isMutating: true,
        errorMessage: null,
        infoMessage: null,
        pendingAddressId: addressId,
      ),
    );

    try {
      final updatedAddress = await _addressRepository.updateAddress(
        userId: userId,
        addressId: addressId,
        payload: payload,
      );
      final updatedList = state.addresses
          .map(
            (address) => address.id == addressId ? updatedAddress : address,
          )
          .toList();

      emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: updatedList,
          isMutating: false,
          infoMessage: 'Address updated successfully',
          pendingAddressId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString(),
          pendingAddressId: null,
        ),
      );
    }
  }

  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    _userId = userId;
    emit(
      state.copyWith(
        isMutating: true,
        errorMessage: null,
        infoMessage: null,
        pendingAddressId: addressId,
      ),
    );

    try {
      final addresses = await _addressRepository.deleteAddress(
        userId: userId,
        addressId: addressId,
      );
      emit(
        state.copyWith(
          status: AddressesStatus.success,
          addresses: addresses,
          isMutating: false,
          infoMessage: 'Address deleted successfully',
          pendingAddressId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString(),
          pendingAddressId: null,
        ),
      );
    }
  }

  void resetMessages() {
    emit(
      state.copyWith(
        errorMessage: null,
        infoMessage: null,
      ),
    );
  }
}

